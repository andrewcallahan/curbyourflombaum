require 'feedzirra'
require 'twilio-ruby'
require 'aws/s3'



# get a random avi quote (well this actually gets an array of all the quotes that you can see without scrolling)
feed = Feedzirra::Feed.fetch_and_parse('http://shitavisays.tumblr.com/rss')

# convert that quote into TwiML (I use the .sample method to pick out a random quote from the array I created)
# I may take down my mp3's listed below, so don't rely on them being on the internet.
xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<Response>
  <Play>https://s3.amazonaws.com/NYConRails/intro.mp3</Play>
  <Pause length=\"0.5\"/>
  <Say voice=\"woman\">#{feed.entries.sample.title.to_s}</Say>
  <Pause length=\"0.5\"/>
  <Play>https://s3.amazonaws.com/NYConRails/exit.mp3</Play>
</Response>"

# save that TwiML as a file to your computer
File.open('call.xml', 'w+') { |f|
  f.puts xml
}


# *** IMPORTANT STEP ***
# make sure you make a bucket on Amazon S3. Mine is 'NYConRails, which you can see below'
# yes I could have done this in code...maybe next time!


# amazon credentials
AWS::S3::Base.establish_connection!(
  :access_key_id     => 'SDF7FS7DFS202S2LKSDS', # <-- put in your own, this is a fake one
  :secret_access_key => 'ASFDHSADF23HSDFASDFJSSX722iaf28#sdfsdf2' # <-- put in your own, this is a fake one
)

# upload TwiML file from your computer to amazon S3
file = 'call.xml'
  AWS::S3::S3Object.store(file, open(file), 'NYConRails', :access => :public_read)



# twilio credentials
account_sid = 'JH96987LKJLKJLKJsadfasdf3323423sfasd' # <-- put in your own, this is a fake one
auth_token = '98273234sdf2342309sd0f9s8fd980s3' # <-- put in your own, this is a fake one
 
# set up a client to talk to the Twilio REST API
@client = Twilio::REST::Client.new account_sid, auth_token
 
# let twilio do it's magic
@call = @client.account.calls.create(
  :from => '+12129983322', # <-- put in your own (must be the one linked to your twilio account), this is a fake one
  :to => '+12123340076', # <-- put in whatever phone number you want to call, this is a fake one
  :url => 'https://s3.amazonaws.com/NYConRails/call.xml', # <-- put in your own, if you use S3 it will just be https://s3.amazonaws.com/YOUR_BUCKET_NAME/call.xml
  :method => 'GET'
)