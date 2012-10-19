@utilities =
  AutoUpdate: (collection) ->
    lastUpdate = -1
    window.Clock.listeners.push ->
      collection.fetch
        add: true
        data:
          id: lastUpdate
      collection.on "add", (model) ->
        lastUpdate = Math.max lastUpdate, (model.id ? -1000)

class Coordinate extends Backbone.Model

class Hint extends Coordinate

class Hunt extends Coordinate

class window.HuntCollection extends Backbone.Collection
  model: Hunt
  url: '/coordinates/hunts'
  comperator: (coord) -> coord.time ? 0
class window.HintCollection extends Backbone.Collection
  model: Hint
  url: '/coordinates/hints'
  comperator: (coord) -> coord.time ? 0