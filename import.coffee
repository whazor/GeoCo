http = require 'http'
db = require './lib/scheme'

options =
  host: 'spreadsheets.google.com'
  port: 80
  path: '/feeds/list/tGmiwetlm27t45ESdPOQCYg/od6/public/basic?alt=json'

data = ''
h = http.get options, (res) ->
  res.on 'data', (chunk) -> data += chunk.toString()
  res.on 'end', ->
    db.User.findOne {'name': 'System'}, (err, user) ->
      if err or user == null
        user = new db.User
          name: 'System'
          ip: '127.0.0.1'

        user.save()

      coordinates = JSON.parse(data).feed.entry

      for coordinate in coordinates
        time = coordinate.title.$t

        [str_date, str_time] = time.split ' '
        str_date = str_date.split '-' if str_date
        str_time = str_time.split ':' if str_time

        str_time = [0, 0, 0] unless str_time

        date = new Date str_date[2], str_date[1], str_date[0], str_time[0], str_time[1], str_time[2]
        groups = coordinate.content.$t.split ', '
        for group in groups when group != ''
          [name, loc] = group.split ': '
          continue if group == 'x'

          [x, y] = loc.split ';'
          [x, y] = [parseFloat(x), parseFloat(y)]
          hint = new db.Hint
            solver: user._id
            fox_group: name
            time: date

          latlang = x < 100 or y < 100
          if latlang
            hint.loc_lng = [x, y]
          else
            hint.loc_rdc = [x, y]

          hint.save()

      console.log 'done'
