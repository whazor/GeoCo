doctype 5
html ->
  head ->
    meta charset: 'utf-8'
    title 'GeoCo'

    link rel: 'stylesheet', href: '/css/master.css'

    script src:"/js/jquery-1.6.4.min.js"
    script src:"/js/jquery-ui-1.9-pre.min.js"
    script src:"/js/bootstrap-dropdown.js"
    script src:"/js/polymaps.min.js"
    script src:"/app.js"
    script "window.loggedin = #{@loggedin};"
  body -> @body
