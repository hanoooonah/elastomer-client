module Elastomer

  def self.router
    Router.instance
  end

  class Router
    include Singleton

    attr_accessor :clients

    #TODO should adapter and index routing be delegated to sub-objects?
    #
    # Is there any reason to have a single object handle both index and adapter routing?

    # What local maps do we need?
    # cluster name => uri maybe?
    # cluster name => client maybe?
    # adapter type => adapter class
    # index name => client
    # index name => index class
    # index name => physical location maybe?

    #TODO use HashWithIndifferentAccess?

    def initialize
      @cluster_clients = {}
      @index_factory   = CachingFactory.new
      @adapter_factory = Factory.new
    end

    def register_cluster(name, url)
      @cluster_clients[name] = Elastomer::Client.new(:url => url)
    end

    def client_for(cluster_name)
      @cluster_clients[cluster_name]
    end

    def register_index_class(name, klass)
      @index_factory.register(name, klass)
    end

    def index_for(name)
      if klass = @index_factory.class_for(name)

        #TODO determine proper client and physical name
        client = client_for('default')
        physical_name = klass.physical_name

        @index_factory.object_for(name, client.index(name))
      end
    end

    def register_adapter_class(type, klass)
      @adapter_factory.register(type, klass)
    end

    def adapter_for(type)
      @adapter_factory.object_for(type)
    end
  end
end