#= require angular
#= require angular-mocks
#= application
describe "PokerController", ->
  
  beforeEach =>
    angular.module('test',['myApp', 'service.userFirebase'])
    userFirebase = jasmine.createSpyObj 'fireMock', ['update']
    userFirebase.currentUser =  new User
    userFirebase.otherUsers = []
    #this marks test and ng modules for injection
    module 'test'
    inject ($rootScope) =>
      @scope = $rootScope.$new()
      @ctrl = new PokerController @scope, userFirebase
      
  it "should have local user", =>
    expect(@scope.me.id).toBeDefined()
    
  it "should change local estimation", =>
    @scope.change_my_estimation(19)
    expect(@scope.me.estimation).toEqual(19)
  
  it "should allow strings in estimations", =>
    @scope.change_my_estimation("?")
    expect(@scope.me.estimation).toEqual("?")
  
  describe "when other users present", =>
    beforeEach =>
      @scope.otherUsers.push new User for i in [1..10]
      
    describe "recognize when everyone ready", =>
      it "when nobody ready", =>
        expect(@scope.everyone_ready()).toBe(false)
      
      it "when only me ready", =>
        @scope.me.estimation = 5
        expect(@scope.everyone_ready()).toBe(false)
      
      it "when only others ready", =>
        for user in @scope.otherUsers
          user.estimation = 1
        expect(@scope.everyone_ready()).toBe(false)
      
      it "when everyone ready", =>
        for user in @scope.otherUsers
          user.estimation = 1
        @scope.me.estimation = 1
        expect(@scope.everyone_ready()).toBe(true)
    
    describe "when clearing estimations", =>
      beforeEach =>
        for user in @scope.otherUsers
          user.estimation = 1
        @scope.me.estimation = 1
      it "should clear everybody", =>
        @scope.clear_everybody()
        for user in @scope.otherUsers
          expect(user.estimation).toBe(undefined)
        expect(@scope.me.estimation).toBe(undefined)
    
    describe "when user is selected and not everyone else ready", =>
      it "should be waiting for others", =>
        @scope.me.estimation = 1
        expect(@scope.selected_user_and_waiting_for_others(@scope.me)).toBe(true)
      it "when not selected", =>
        expect(@scope.selected_user_and_waiting_for_others(@scope.me)).toBe(false)
      it "when everyone ready", =>
        for user in @scope.otherUsers
          user.estimation = 1
        @scope.me.estimation = 1
        expect(@scope.selected_user_and_waiting_for_others(@scope.me)).toBe(false)
        
        