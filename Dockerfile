# Start from the latest Ruby image
FROM ruby:latest


# Install Git
RUN apt-get update -qq && apt-get install -y git && apt-get install -y ruby-dev  
# can be removed?? 

# Install bundler and update system gems
RUN gem install bundler
RUN gem update --system
RUN gem update

# # Link /bin/bash to /bin/sh
# RUN ln -sf /bin/bash /bin/sh

# Run shell
RUN bash



# install vim, cat 