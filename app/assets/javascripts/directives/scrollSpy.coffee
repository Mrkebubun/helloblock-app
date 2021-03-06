hbApp.directive 'spy', ($location) ->
  restrict: "A"
  require: "^scrollSpy"
  link: (scope, elem, attrs, scrollSpy) ->
    attrs.spyClass ?= "active"

    $(".bs-sidenav ul.nav").hide()

    scrollSpy.addSpy
      id: attrs.spy
      in: -> elem.addClass attrs.spyClass,
      out: -> elem.removeClass attrs.spyClass

hbApp.directive 'scrollSpy', ($window, $timeout) ->
  restrict: 'A'
  controller: ($scope) ->
    $scope.spies = []
    @addSpy = (spyObj) ->
      $scope.spies.push spyObj
    return

  link: (scope, elem, attrs) ->
    spyElems = []

    $timeout ->
      scope.$watch 'spies', (spies) ->

        for spy in spies
          unless spyElems[spy.id]?
            spyElems[spy.id] = elem.find('#'+spy.id)

    $(window).scroll ->
      highlightSpy = null

      for spy in scope.spies
        spy.out()

        # the elem might not have been available when it was originally cached,
        # so we check again to get another element in case this one doesn't exist.
        spyElems[spy.id] =
          if spyElems[spy.id] is undefined
            elem.find('#'+spy.id)
          else
            spyElems[spy.id]


        # the element could still not exist, so we check first to avoid errors
        if spyElems[spy.id].length isnt 0
          pos = spyElems[spy.id].offset().top
          if pos - $window.scrollY <= 0
            spy.pos = pos

            highlightSpy ?= spy

            if highlightSpy.pos < spy.pos
              highlightSpy = spy

              $(".bs-sidenav ul.nav").hide()
              $(".bs-sidenav #resource-" + spy.id).children().show()
              $(".bs-sidenav ul.nav #sidebar-" + spy.id).parent().show()


      if highlightSpy
        highlightSpy.in()
