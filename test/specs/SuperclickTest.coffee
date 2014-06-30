$ = jQuery

describe "Superclick", ->

  $menu = null
  $li_with_sub = null

  beforeEach ->
    $menu = $('ul.sf-menu')
    $li_with_sub = $menu.find('li:has(ul):first')
    $menu.superclick()
  
  afterEach ->
    $menu.superclick('destroy')

  it "should exist", ->
    expect($.fn.superclick).toBeDefined()

  it "should be chainable", ->
    $menu.superclick('destroy')
    expect($menu.superclick()).toBe 'ul'

  it "should store options", ->
    expect($menu.data('sf-options') ).toBeDefined()


  describe "options", ->

    it "should have default options", ->
      options = $menu.data('sf-options')
      expect(options.speed).toMatch 'normal'

    it "should allow default options to be overridden", ->
      $menu.superclick('destroy')
      $menu.superclick
        speed: 1000
      options = $menu.data('sf-options')
      expect(options.speed).toEqual 1000


  describe "method access", ->

    it "'show' method should exist", ->
      expect($li_with_sub.superclick('show')).toBeDefined()

    it "'hide' method should exist", ->
      expect($li_with_sub.superclick('hide')).toBeDefined()

    it "'destroy' method should exist", ->
      expect($menu.superclick('destroy')).toBeDefined()
      $menu.superclick()

    it "should not allow access to private functions", ->
      expect( ->
        $menu.superclick('close')
      ).toThrow new Error('Method close does not exist on jQuery.fn.superclick')

    it "should not throw an error when accessing a valid method", ->
      expect( ->
        $li_with_sub.superclick('show')
      ).not.toThrow new Error('Method show does not exist on jQuery.fn.superclick')


  describe "'destroy' method", ->

    it "should handle multiple calls gracefully", ->
      $menu.superclick('destroy')
      expect( ->
        $menu.superclick('destroy')
      ).not.toThrow new Error("Uncaught TypeError: Cannot read property 'sfTimer' of null")
      expect($menu.superclick('destroy')).toBe 'ul'


  describe "'show' method", ->
    it "should fail silently if Superclick is uninitialised", ->
      $menu.superclick('destroy')
      expect( $li_with_sub.superclick('show') ).toBe 'li'

    it "should cause child ul to be visible", ->
      $submenu = $li_with_sub.children('ul')
      expect($submenu).toBeHidden()
      expect($li_with_sub).not.toBe '.sfHover'
      $li_with_sub.superclick('show')
      expect($submenu).toBeVisible()
      expect($li_with_sub).toBe '.sfHover'


  describe "'hide' method", ->
    it "should fail silently if Superclick is uninitialised", ->
      $menu.superclick('destroy')
      expect( $li_with_sub.superclick('hide') ).toBe 'li'
      
    it "should cause child ul to be hidden", ->
      $submenu = $li_with_sub.children('ul')
      $li_with_sub.superclick('show')
      expect($li_with_sub).toBe '.sfHover'
      expect($submenu).toBeVisible()
      # do an instant hide for now until I figure out why .toBeHidden fails when animated
      $li_with_sub.superclick('hide', true)
      expect($submenu).toBeHidden()
      expect($li_with_sub).not.toBe '.sfHover'


  describe "initialisation", ->
    it "should fail silently if already initialised", ->
      $menu.superclick('destroy')
      init_count = 0
      $.fn.superclick.defaults.onInit = -> init_count++
      $menu.superclick().superclick()
      expect(init_count).toEqual 1
      $.fn.superclick.defaults.onInit = $.noop

    it "should be able to store the path to the 'current' menu item (pathClass)", ->
      expect($menu.data('sf-options').$path.length).toEqual 0
      $menu.superclick('destroy')
      $menu.superclick
        pathClass: 'current'
      expect($menu.data('sf-options').$path.length).toEqual 1


  describe "pathClass feature", ->
    it "should show 'current' submenu", ->
      $menu.superclick('destroy')
      $menu.superclick
        pathClass: 'current'
      expect($li_with_sub).toBe '.sfHover'


  describe "callbacks", ->

    describe "onDestroy", ->
      it "should fire", ->
        destroy_count = 0
        $menu.superclick('destroy')
        $menu.superclick
          onDestroy: -> destroy_count++
        $menu.superclick('destroy')
        console.log destroy_count
        expect(destroy_count).toEqual 1
