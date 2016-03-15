# Description:
#   Allows for Hubot to let you know whats on tap
#

# Commands:
#   hubot keg me - Returns Kegerator Statistics
#
# Configuration:
#  HUBOT_KEGBOT_URL - URL to kegbot root. ie: http://kegbot.mydomain.com
#  HUBOT_KEGBOT_TOKEN - API Token to access your kegbot's API
#
# Author:
#   Marc Missey
#   marcmissey@gmail.com

  KEGBOT_URL = null
  TOKEN = null
  module.exports = (robot)->

    unless process.env.HUBOT_KEGBOT_URL?
      console.log 'The HUBOT_KEGBOT_TOKEN environment variable not set'
      robot.logger.warning 'The HUBOT_KEGBOT_URL environment variable not set'
      return

    unless process.env.HUBOT_KEGBOT_TOKEN?
      console.log 'The HUBOT_KEGBOT_TOKEN environment variable not set'
      robot.logger.warning 'The HUBOT_KEGBOT_TOKEN environment variable not set'
      return

    robot.hear /keg me/i, (res) ->
      send_keg_stats res
      return

    robot.hear /what\'?s\s*on\s*tap/i, (res) ->
      send_keg_stats res
      return

  send_keg_stats = (message) ->
    KEGBOT_URL = process.env.HUBOT_KEGBOT_URL
    TOKEN = process.env.HUBOT_KEGBOT_TOKEN

    url = KEGBOT_URL + "/api/taps";
    message.http( url )
    .headers("X-Kegbot-Api-Key": TOKEN)
    .get() (error, response, body)->
      body = JSON.parse body
      msg = ''
      try
        for tap, index in body.objects
          location = tap.name

          if location.length <= 13
            count = location.length
            for i in [count..12] by 1
              location += ' '

          keg = tap.current_keg
          unless keg
            msg += "#{location}: No keg on Tap\n"
            continue

          #image = keg?.beverage.picture?.thumbnail_url
          #message.send image if image

          name = keg.type.name
          style = keg.beverage.style
          producer = keg.beverage.producer.name
          percentage_left = Math.round(keg.percent_full)
          pints = Math.round(keg.size_volume_ml / 473.176)
          id = keg.id
          link = "#{KEGBOT_URL}/kegs/#{id}"
          percentLeft = Math.floor keg.percent_full
          abv = "#{keg.type.abv}%"

          msg += "#{location}: #{name} (#{style})"
          msg +=  " by #{producer}" if producer
          msg +=  " - #{abv} ABV" if abv
          msg +=  " - #{percentage_left}% Remaining (~ #{pints} Pints)"

          msg += "\n"
          #msg += " - #{link}\n"
      catch error
        console.log error


      # If we got a message out of all of that, send it
      try
        if msg
            msg = '```' + msg + '```'
            message.send msg
        unless msg
            message.send "I'm so sorry. There is no beer on tap."
      catch error
        console.log error
    return
