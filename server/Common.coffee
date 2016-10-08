# msnodesql doesn't check hasOwnProperty when enumerating over arrays, so it
# goes nuts if the below monkeypatched methods are enumerable.

async = require 'async'

defineMethod = (classname, name, value) ->
    Object.defineProperty classname.prototype, name, { enumerable: false, value: value }
    
defineMethod Array, 'remove', (item) ->
    idx = @indexOf(item)
    @splice(idx, 1) if idx >= 0
    
defineMethod Array, 'removeIf', (fn) -> @[..] = @filter((i) -> not fn(i))
defineMethod Array, 'shuffle', ->
    for i in [0 ... @.length]
        j = Math.floor(Math.random() * (@.length - i) + i)
        [@[i], @[j]] = [@[j], @[i]]

defineMethod String, 'trim', ->
    return String(this).replace(/^\s+|\s+$/g, '')

ORIGINAL_GAMETYPE = 1
AVALON_GAMETYPE = 2
BASIC_GAMETYPE = 3
# not really a gametype, but stored in the DB to distinguish Avalon games 
# roles besides Merlin and Assassin.
AVALON_PLUS_GAMETYPE = 4 
HUNTER_GAMETYPE = 5
# also not really a gametype, but stored in the DB to distinguish Hunter games 
# roles besides Chiefs and Hunters.
HUNTER_PLUS_GAMETYPE = 6

allGameTypes = [ORIGINAL_GAMETYPE, AVALON_GAMETYPE, BASIC_GAMETYPE, HUNTER_GAMETYPE]

gameTypeNames =
    1: 'Original'
    2: 'Avalon'
    3: 'Basic'
    5: 'Hunter'

xmlEscape = (s) ->
    return s
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/'/g, '&apos;')
        .replace(/"/g, '&quot;')

# The global hash.  Commented-out fields are initialized later on 
# (after said classes are defined).

g =
    playersById: {}
    playersBySessionKey: {}
    mutedPlayers: []
    # db: new Database()
    # stats: new Statistics()
    # lobby: new Lobby()
    # specialMode: 0
