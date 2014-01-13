# Use as: eval `./setenv.sh`
FLICKR_API_KEY=`heroku config:get FLICKR_API_KEY`
echo "export FLICKR_API_KEY=$FLICKR_API_KEY"
