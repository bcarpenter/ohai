#
# Author:: Doug MacEachern <dougm@vmware.com>
# Author:: Theodore Nordsieck (<theo@opscode.com>)
# Copyright:: Copyright (c) 2009 VMware, Inc.
# Copyright:: Copyright (c) 2013 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '/spec_helper.rb'))

describe Ohai::System, "plugin lua" do

  before(:each) do
    @plugin = get_plugin("lua")
    @plugin[:languages] = Mash.new
    @status = 0
    @stdout = ""
    @stderr = "Lua 5.1.2  Copyright (C) 1994-2008 Lua.org, PUC-Rio\n"
    @plugin.stub(:run_command).with({:no_status_check=>true, :command=>"lua -v"}).and_return([@status, @stdout, @stderr])
  end

  it "should get the lua version from running lua -v" do
    @plugin.should_receive(:run_command).with({:no_status_check=>true, :command=>"lua -v"}).and_return([0, "", "Lua 5.1.2  Copyright (C) 1994-2008 Lua.org, PUC-Rio\n"])
    @plugin.run
  end

  it "should set languages[:lua][:version]" do
    @plugin.run
    @plugin.languages[:lua][:version].should eql("5.1.2")
  end

  it "should not set the languages[:lua] tree up if lua command fails" do
    @status = 1
    @stdout = ""
    @stderr = "Lua 5.1.2  Copyright (C) 1994-2008 Lua.org, PUC-Rio\n"
    @plugin.stub(:run_command).with({:no_status_check=>true, :command=>"lua -v"}).and_return([@status, @stdout, @stderr])
    @plugin.run
    @plugin.languages.should_not have_key(:lua)
  end

  require File.expand_path(File.join(File.dirname(__FILE__), '..', 'path', '/ohai_plugin_common.rb'))

  test_plugin([ "languages", "lua" ], [ "lua" ]) do | p |
    p.test([ "centos-6.4" ], ["x86", "x64"], [[], ["lua"]],
           { "languages" => { "lua" => { "version" => "5.1.4" }}})
    p.test([ "ubuntu-10.04", "ubuntu-12.04" ], [ "x86", "x64" ], [[]],
           { "languages" => { "lua" => nil }})
    p.test([ "ubuntu-13.04" ], [ "x64" ], [[]],
           { "languages" => { "lua" => nil }})
    p.test([ "ubuntu-10.04", "ubuntu-12.04" ], [ "x86", "x64" ], [[ "lua" ]],
           { "languages" => { "lua" => { "version" => "5.1.4" }}})
    p.test([ "ubuntu-13.04" ], [ "x64" ], [["lua"]],
           { "languages" => { "lua" => { "version" => "5.1.5" }}})
  end
end
