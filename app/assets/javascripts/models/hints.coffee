@utilities =
  AutoUpdate: (collection) ->
    lastUpdate = -1
    lastUpdateTime = 0
    window.Clock.listeners.push ->
      collection.fetch
        add: true
        data:
          id: lastUpdate
          updateAt: lastUpdateTime
      collection.on "add", (model) ->
        lastUpdate = Math.max lastUpdate, (model.id ? -1000)
        lastUpdateTime = Math.max lastUpdateTime, (model.updateAt ? 0)

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