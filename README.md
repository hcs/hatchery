Hatchery
========

![Cute chicks!](http://i.imgur.com/USBB9.jpg)

(It's actually named after the Zerg building, but who's counting?)


Setting up Hatchery
-------------------

Hatchery stores its secrets in the aptly named "secrets" repository, which is
linked here via git submodules. If you have access to the secrets repository,
you can set up hatchery by doing the following:

    git clone git@github.com:hcs/hatchery.git
    git submodule init
    git submodule update

Look at the documentation in the secrets repository for more about how secrets
work. The TL;DR is that secrets are encrypted to each individual with access via
GPG.


Using Hatchery
--------------

Hatchery is written as a Ruby library, and can be used from Ruby scripts or
through an interactive Ruby shell such as `irb`. Below is a sample interactive
session:

    auri:hatchery carl$ irb -r hatchery.rb
    >> s = Server.new 'generic1'
    => #<GenericServer:0x1017f3490 @hostname=generic1.hcs.harvard.edu, @instance=nil>
    >> s.create
    I, [2012-12-22T16:14:29.849570 #14029]  INFO -- : About to start instance generic1.hcs.harvard.edu of type GenericServer
    I, [2012-12-22T16:14:30.660145 #14029]  INFO -- : Waiting for generic1.hcs.harvard.edu
    I, [2012-12-22T16:14:50.555876 #14029]  INFO -- : Launched instance i-48290236, status: running
    I, [2012-12-22T16:14:50.875313 #14029]  INFO -- : Allocating an IP address for the new instance
    I, [2012-12-22T16:14:51.679098 #14029]  INFO -- : Allocated IP 107.23.140.214
    I, [2012-12-22T16:14:51.800351 #14029]  INFO -- : Trying to SSH to 107.23.140.214
    I, [2012-12-22T16:15:13.180325 #14029]  INFO -- : We're in! Calling SSH hook.

    ... chunder chunder chunder ...

    I, [2012-12-22T16:15:39.849652 #14029]  INFO -- : Everything is shiny. Have fun with generic1.hcs.harvard.edu
    => true
    >> s.ip_address
    => "107.23.140.214"
    >> s.id
    => "i-48290236"
    >> s.private_ip_address
    => "10.0.2.200"
    >> s.instance
    => <AWS::EC2::Instance id:i-48290236>
    >> s.terminate
    => nil

The `AWS::EC2::Instance` at the end is an object from the official [aws-sdk
gem][gem] and can be fiddled with to your heart's content.

[gem]: http://docs.amazonwebservices.com/AWSRubySDK/latest/frames.html
