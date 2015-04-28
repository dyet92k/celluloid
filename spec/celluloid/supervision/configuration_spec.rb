RSpec.describe Celluloid::Supervision::Configuration, actor_system: :global do

  class TestActor
    include Celluloid
    def identity
      :testing
    end
  end

  let(:succeeding) {
    {
      :as => :testing,
      :type => TestActor
    }
  }

  let(:failing) {
    {
      :as => :testing,
      :type => TestActor,
      :args => [ :fail ]
    }
  }

  after(:each) {
    Celluloid::Supervision::Configuration.resync_parameters
    subject.resync_accessors
  }

  context("remains reusable without being mutated") {
    it("properly") {
      expect(Celluloid.actor_system.root_configuration.export).to eq(Celluloid::ActorSystem::ROOT_SERVICES)
    }
  }

  context("metaprogramming") {

    context("Celluloid.services accessor") {
      it("is dynamically added, and available") {
        expect(Celluloid.services.respond_to? :supervise).to be_truthy
      }
      it("allows supervision"){
        Celluloid.services.supervise(type: TestActor, as: :test_actor)
        expect(Celluloid.services.test_actor.identity).to eq(:testing)
      }
    }

    context("supervised actors can create accessors") {
      it("which are dynamically added, and available as Celluloid.accessor") {
        TestActor.supervise(as: :test_actor, accessors: [ :test_actor ])
        expect(Celluloid.test_actor.identity).to eq(:testing)
      }
    }
  }

  context("parameters") {

    context("can be added to") {

      context("can be given new :mandatory parameters") {
        
        before(:each){
          Celluloid::Supervision::Configuration.parameter! :mandatory, :special_requirement
          subject.resync_accessors
        }

        it("programmatically") {
          expect(Celluloid::Supervision::Configuration.parameters(:mandatory)).to include(:special_requirement)
        }

        it("and respond appropriately") {
          subject.resync_accessors
          expect(subject.methods).to include(:special_requirement)
          expect(subject.respond_to?(:special_requirement!)).to be_truthy
          expect(subject.respond_to?(:special_requirement?)).to be_truthy
          expect(subject.respond_to?(:special_requirement=)).to be_truthy
          expect(subject.respond_to?(:special_requirement)).to be_truthy

        }

        it("and instances will respond appropriately") {
          subject.instances.first.resync_accessors
          subject.define( type: TestActor, special_requirement: :valid )
          expect(subject.respond_to?(:special_requirement)).to be_truthy
        }

        it("and be reset to defaults") {
          Celluloid::Supervision::Configuration.resync_parameters
          expect(Celluloid::Supervision::Configuration.parameters(:mandatory)).not_to include(:special_requirement)
        }
      }

      context("can be aliased") {

        before(:each) {
          Celluloid::Supervision::Configuration.resync_parameters
          Celluloid::Supervision::Configuration.alias! :nick, :as
          subject.resync_accessors
        }

        it("programmatically") {
          expect(Celluloid::Supervision::Configuration.aliases.keys).to include(:nick)
        }

        it("and respond appropriately by method") {
          subject.define( type: TestActor, as: :test_name )
          expect(subject.respond_to?(:nick!)).to be_truthy
          expect(subject.respond_to?(:nick?)).to be_truthy
          expect(subject.respond_to?(:nick=)).to be_truthy
          expect(subject.respond_to?(:nick)).to be_truthy
          expect(subject.nick).to eq(:test_name)
        }

        xit("and respond properly by current_instance, by method") {
          # subject.current_instance[:aliased] gets subject.current_instance[:original]
        }

        it("and instances will respond properly by method") {
          subject.define( as: :test_name, type: TestActor )
          expect(subject.instances.first.respond_to?(:nick!)).to be_truthy
          expect(subject.instances.first.respond_to?(:nick?)).to be_truthy
          expect(subject.instances.first.respond_to?(:nick=)).to be_truthy
          expect(subject.instances.first.respond_to?(:nick)).to be_truthy
          expect(subject.instances.first.nick).to eq(:test_name)
        }

        xit("and respond appropriately by key") {
          # subject[:aliased] gets subject[:original]
        }
        
        xit("and instances respond properly by current_instance, by key") {
          # subject.instances.first[:aliased] gets subject.instances.first[:original]
        }
        
        xit("and instances respond properly by key") {
          # subject.instances.first[:aliased] gets subject.instances.first[:original]
        }

      }
    }
  }

  context("Configuration.define class method") {

    xit("can take individual instance configuration") {

    }

    xit("can take array of instance configurations") {

    }

  }

  context("Configuration#define instance method") {

    xit("can take individual instance configuration") {

    }

    xit("can take array of instance configurations") {

    }

  }

  context("Configuration.deploy class method") {

    xit("can take individual instance configuration") {

    }

    xit("can take array of instance configurations") {

    }

  }

  context("Configuration#deploy instance method") {

    xit("can take individual instance configuration") {

    }

    xit("can take array of instance configurations") {

    }

  }

  context("accessing information") {

    before(:each) { subject.define(succeeding) }
    it("can get values out of current level of configuration by [:key]") {
      expect(subject[:as]).to eq(:testing)
    }

    it("can get values out of current level of configuration by #key") {
      expect(subject.as).to eq(:testing)
    }

  }

  it("verifies arity of intended actor's initialize method") {
    expect { subject.define(failing) }.to raise_exception(ArgumentError)
  }

end