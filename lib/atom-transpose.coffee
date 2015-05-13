{CompositeDisposable} = require 'atom'

module.exports = AtomTranspose =
  subscriptions: null

  activate: (state) ->
    # Register command that toggles this view
    atom.commands.add 'atom-workspace', 'atom-transpose:transpose': => @transpose()

  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-transpose:transpose': => @transpose()

  deactivate: ->
    @subscriptions.dispose()

  transpose: ->
    reverseText = (selection) ->
      selection.insertText selection.getText().split('').reverse().join('')

    exchange = (selection) ->
      selection.selectRight()
      text = selection.getText()
      selection.delete()
      selection.cursor.moveLeft()
      selection.insertText text

    exchangeOrReverse = (selection) ->
      if selection.isEmpty()
        exchange selection
      else
        reverseText selection

    if editor = atom.workspace.getActiveTextEditor()
      selections = editor.getSelections() || []
      if selections.length == 2
        selectionLeft = selections[0]
        selectionRight = selections[1]
        if selectionLeft.isEmpty() || selectionRight.isEmpty()
          exchangeOrReverse selectionLeft
          exchangeOrReverse selectionRight
        else
          textLeft = selectionLeft.getText()
          textRight = selectionRight.getText()

          selectionLeft.delete()
          selectionLeft.insertText textRight
          selectionLeft.selectLeft(textRight.length)

          selectionRight.delete()
          selectionRight.insertText textLeft
          selectionRight.selectLeft(textLeft.length)
      else
        selections.forEach (selection) ->
          exchangeOrReverse selection
