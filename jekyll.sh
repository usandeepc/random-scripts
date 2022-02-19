# Run Jekyll With out installing Ruby and Dependencies


# Create New Site

docker run --rm   --volume="$PWD:/srv/jekyll"   --publish 4000:4000   jekyll/jekyll   jekyll new .

#Serve the site

docker run --rm   --volume="$PWD:/srv/jekyll"   --publish 4000:4000   jekyll/jekyll   jekyll serve
