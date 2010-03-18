require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe PivotalTrackerClient do
  context "on init with a token" do
    before :each do
      Rufus::Scheduler.stub(:start_new).and_return(@scheduler = mock(Object, :every => nil))
    end

    it "should save the id of the latest activity" do
      client = PivotalTrackerClient.init '123456789' 
      client.id.should == '25906467'
    end
  
    it "should request the feed with the token" do
      token = '34g43g4334g43g43'
      RestClient.should_receive(:get) do |url, opts|
        opts['X-TrackerToken'].should eql(token)
        mock(Object, :body => latests_activities)
      end
      PivotalTrackerClient.init token
    end

    it "should fetch new activities every 30 seconds" do
      @scheduler.should_receive(:every).with('30s')
      PivotalTrackerClient.init 'fegegege'
    end

    it "should fetch new activities" do
      @scheduler.stub(:every) do |time, block|
        block.call
      end
      RestClient.should_receive(:get).exactly(2).times do
        mock(Object, :body => latests_activities)
      end
      PivotalTrackerClient.init 'fegegege'
    end
  end

  context "on update" do
    before :each do
      @client = PivotalTrackerClient.init('fake')
      @client.stub! :system
      @client.instance_variable_set "@id", '25906311'
    end

    it "should get the new activities and update the id" do
      @client.update
      @client.id.should == '25906467'
    end

    it "should notifify about each new activity" do
      @client.should_receive(:system).exactly(2).times
      @client.update
    end

    context "on os x" do
      it "should notify growl calling growlnotify with 'Pivotal Tracker' as the name the application, the author and the action" do
        @client.should_receive(:system).with("growlnotify -t 'Pivotal Tracker' -m 'Superman finished lorem ipsum'")
        @client.update
      end

      it "should notify newer activities at least" do
        @client.should_receive(:system).with("growlnotify -t 'Pivotal Tracker' -m 'SpongeBog finished lorem ipsum'").ordered
        @client.should_receive(:system).with("growlnotify -t 'Pivotal Tracker' -m 'Superman finished lorem ipsum'").ordered
        @client.update
      end
    end
  end
end
