###
 * Federated Wiki : Slide Plugin
 *
 * Licensed under the MIT license.
 * https://github.com/wardcunningham/wiki-plugin-slide/blob/master/LICENSE.txt
###

lineNumber = 0
totalLines = 0

headers = (line) ->
  line = line.replace /^#+(.*)$/, '<h3>$1</h3>'

emphasis = (line) ->
  line = line.replace /\*\*(\S.*?\S)\*\*/g, '<b>$1</b>'
  line = line.replace /\_\_(\S.*?\S)\_\_/g, '<b>$1</b>'
  line = line.replace /\*(\S.*?\S)\*/g, '<i>$1</i>'
  line = line.replace /\_(\S.*?\S)\_/g, '<i>$1</i>'
  line = line.replace /\*\*(\S)\*\*/g, '<b>$1</b>'
  line = line.replace /\_\_(\S)\_\_/g, '<b>$1</b>'
  line = line.replace /\*(\S)\*/g, '<i>$1</i>'
  line = line.replace /\_(\S)\_/g, '<i>$1</i>'

lists = (line) ->
  line = line.replace /^ *[*-] +(\[[ x]\])(.*)$/, (line, box, content) ->
    checked = if box == '[x]' then  ' checked' else ''
    "<li><input type=checkbox data-line=#{lineNumber}#{checked}>#{content}</li>"
  line = line.replace /^ *[*-] +(.*)$/, '<li>$1</li>'

escape = (line) ->
  line
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')

code = (line) ->
  styles = 'background:rgba(0,0,0,0.04);padding:0.2em 0.4em;border-radius:3px'
  line.replace /`(\S.*?\S)`/g, "<code style=\"#{styles}\">$1</code>"

breakLine = (line) ->
  exp = /// (
    [^>]+            # does not end with a tag
    | <\/(i|b|code)> # or the tag is an inline tag (<i>, <b> or <code>)
  ) $ ///

  if lineNumber != totalLines - 1 and exp.test line
    "#{line}<br>"
  else
    line

expand = (text) ->
  lines = text.split /\n/
  totalLines = lines.length
  lineNumber = -1

  output = for line in lines
    lineNumber++
    breakLine emphasis headers lists code escape line
  output.join ""

emit = ($item, item) ->
  $item.append """
    <div style="background-color: #ddd; padding: 16px; height: 202px; margin-bottom: 4px;">
      #{wiki.resolveLinks item.text, expand}
      <span class="start" style="color: #eee; float: right; font-size: x-large; cursor: pointer;">▶</span>
    </div>
  """

toggle = (item, lineNumber) ->
  lines = item.text.split /\n/
  lines[lineNumber] = lines[lineNumber].replace /\[[ x]\]/, (box) ->
    if box == '[x]' then '[ ]' else '[x]'
  item.text = lines.join "\n"

bind = ($item, item) ->
  $item.dblclick -> wiki.textEditor $item, item
  $item.find('[type=checkbox]').change (e) ->
    toggle item, $(e.target).data('line')
    $item.empty()
    emit($item, item)
    bind($item, item)
    wiki.pageHandler.put $item.parents('.page:first'),
      type: 'edit',
      id: item.id,
      item: item
  $item.find('.start').click ->
    html = null
    mock =
      append: (string) ->
        html = string
    emit mock, item
    wiki.dialog 'Fullscreen Text', """<div style="transform: matrix(1.2,0,0,1.2,460,60) scale(1.6,1.6)">#{html}</div>"""
window.plugins.slide = {emit, bind} if window?
module.exports = {expand} if module?
