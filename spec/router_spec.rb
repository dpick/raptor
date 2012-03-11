require "rack"
require "spec_helper"
require "raptor"

describe Raptor::Router do
  describe "when a route isn't defined" do
    it "raises an error" do
      env = env('GET', '/doesnt_exist')
      router = Raptor::Router.new(stub(:app), [])
      response = router.call(env)
      response.status.should == 404
    end
  end

  describe 'with custom injectables' do
    it 'sets the params with the custom injectable' do
      module Foo
        module Presenters
          class Post
            def initialize(subject); @subject = subject; end
          end
        end

        module Records
          class Post
            def self.all(watermelon); watermelon.should == 'tasty'; nil; end
          end
        end

        module Presenters
          class PostList
            def all
              RouterTestApp::Records::Post.all
            end
          end
        end

        module Injectables
          class Fruit
            def sources(injector)
              {:watermelon => lambda { "tasty" } }
            end
          end
        end
      end

      params = {:present => :post_list, 
                :to => "Records::Post.all",
                :action => :index, 
                :http_method => "GET",
                :path => "/post/"}

      routes = [Raptor::Route.for_app_module(Foo, '', params)]

      router = Raptor::Router.new(Foo, routes)
      Raptor::Template.stub(:from_path => stub(:render => ""))

      router.call(env('GET', '/post'))
    end
  end
end
