{CompositeDisposable} = require 'atom'

module.exports = AtomTranspose =
  subscriptions: null

  activate: ->
    # Register command that toggles this view
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-text-editor', 'atom-transpose:transpose': => @transpose()

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

    getSelectedText = (selection) ->
      if selection.isEmpty()
        selection.selectWord()
      selection.getText()

    if editor = atom.workspace.getActiveTextEditor()
      checkpoint = editor.createCheckpoint()
      selections = editor.getSelections() || []
      # Multiple selections
      if selections.length >= 2
        isAllEmpty = selections.reduce(((res, selection) -> res && selection.isEmpty()), true);
        # If all selections are empty, then select words
        if isAllEmpty
          selections.map getSelectedText

        # Else transpose them by clock order
        else
          texts = selections.map getSelectedText
          texts.push texts.shift()
          selections.forEach (selection, i) ->
            selection.insertText texts[i]

      # Single selection
      else
        selection = selections[0]
        # if selection is empty, then reverse the sibling letter
        # else reverse the whole selection
        if selection.isEmpty() then exchange(selection) else reverseText(selection)

      editor.groupChangesSinceCheckpoint(checkpoint)
