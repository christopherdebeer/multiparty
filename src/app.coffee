
Backbone = require('backbone')
Entropy = window.E = require( './Entropy.coffee' )




class Address extends Backbone.Model
  initialize: ({name, m, n, p} ={}) ->
    @genKeys()
    @set( 'name', name or 'Untitled' )
    @set( 'p', p or [] )
    @set( 'm', m or 1 )
    @set( 'n', @get('p').length + 1 )
    @set( 'txs', 0 )
    @genASM()

  genKeys: ->
    PrivateKey = Bitcoin.ECKey.makeRandom( false )

    @set 'keys',
      address: PrivateKey.pub.getAddress().toString()
      private: PrivateKey.toWIF()
      public: PrivateKey.pub.toHex()
  
  genASM: ->
    pubKeys = [@get('keys').public].concat( x for x in @get('p') ).map Bitcoin.ECPubKey.fromHex
    Script = Bitcoin.scripts.multisigOutput( @get('m'), pubKeys )
    @set( 'asm', Script.toASM() )
    
class AddressCollection extends Backbone.Collection
  model: Address

addresses = window.addresses = []






app = angular.module 'multiparty', ['ui.bootstrap', 'ngTouch', 'Entropy', 'ngStorage']


app.run ['$rootScope', ($rootScope) ->
  console.log 'running...'

  #let everthing know that we need to save state now.
  window.onbeforeunload = (event) ->
    console.log 'save state'
    $rootScope.$broadcast( 'savestate' )
]


app.factory 'UserService', ['$rootScope', ($rootScope) ->
  service =
    addrs: angular.fromJson( sessionStorage.userService ) or addresses
    list: -> service.addrs
    add: (a) ->
      service.addrs.push a
      service.save()
    remove: (a) -> 
      idx = service.addrs.indexOf( a )
      service.addrs.splice( idx, 1 ) if idx > -1
      service.save()
    save: -> 
      console.log 'saving...'
      sessionStorage.userService = angular.toJson( service.addrs )
    restore: -> 
      console.log 'restoring...'
      service.addrs = angular.fromJson( sessionStorage.userService )

  $rootScope.$on( "savestate", service.save )
  $rootScope.$on( "restorestate", service.restore ) 
  service
]

app.controller 'AddressesCtrl', ['$scope', 'UserService', ($scope, UserService) ->
  $scope.addresses = UserService.list()
  $scope.add = (a) -> UserService.add( a )
  $scope.remove = (a) -> window.confirm( 'Are you sure?' ) and UserService.remove( a )
]

app.directive 'addressList', ->
  template: """
  <ul class="addresses list-group" ng-controller="AddressesCtrl">
    <li class="address list-group-item" ng-repeat="address in addresses"  ng-swipe-left="showActions = false" ng-swipe-right="showActions = true" >
      <div class="actions" ng-show="showActions">
        <span class="glyphicon glyphicon-remove" ng-click="remove(address)"></span>
      </div>
      <div class="info" ng-controller="AddressCtrl" ng-click="show(address); showActions = false" >
        <span class="title">{{address.name}}</span>
        <span class="badge alert-success">{{address.txs || 0}}</span>
        <span class="badge alert-success">{{address.m}}/{{address.n}}</span>
      </div>                  
    </li>

    <li class="list-group-item" class="create" ng-controller="CreateNewCtrl">
        <button ng-click="open()" type="button" class="btn btn-primary">Create</button>
    </li>
  </ul>
  """



app.controller 'CreateNewCtrl', ['$scope', '$modal', 'UserService', ($scope, $modal, UserService) ->
  CreateNewInstanceCtrl = ($scope, $modalInstance) ->
    
    $scope.addressModel = new Address()
    $scope.address = $scope.addressModel.toJSON()

    $scope.ok = ->
      UserService.add( $scope.address )
      $modalInstance.close()

    $scope.cancel = -> $modalInstance.dismiss('cancel')

    $scope.gen = ->
      $scope.addressModel = new Address( name: $scope.address.name )
      $scope.address = $scope.addressModel.toJSON()


  $scope.open = (size) ->
    modal = $modal.open
      template: """
      <div class="modal-header">New multiparty Root Key : {{address.name}}</div>
      <div class="modal-body">
        <form class="form">
          <div class="form-group">
            <input type="text" placeholder="Name" ng-model="address.name">
          </div>
          <div class="form-group">
            <p>address: {{address.keys.address}}</p>
            <p>public: {{address.keys.public}}</p>
            <p>private: {{address.keys.private}}</p>
            <button ng-click="gen()" type="button" class="btn btn-primary">Generate</button>
          </div>
          <div class="form-group">
            <label for="">m</label>/<label for="">n</label>
            <input type="number" value="1" ng-model="address.m">/<input type="number" value="1" ng-model="address.n">
          </div>
        </form>
      </div>
      <div class="modal-body">
        <button ng-click="cancel()" type="button" class="btn btn-primary">Cancel</button>
        <button ng-click="ok()" type="button" class="btn btn-primary">Ok</button>
      </div>
      """
      controller: CreateNewInstanceCtrl
      size: size
]





app.controller 'AddressCtrl', ['$scope', '$modal', ($scope, $modal) ->
  AddressInstanceCtrl = ($scope, $modalInstance, address) ->
    $scope.address = address 
    $scope.back = ->
      $modalInstance.dismiss('cancel')

  $scope.show = (address) ->
    console.log address
    modal = $modal.open
      controller: AddressInstanceCtrl
      resolve:
        address: -> address
      template: """
        <div class="modal-header"><button ng-click="back()" type="button" class="btn btn-primary">Back</button></div>
        <div class="modal-body address" >
          <div class="info">
            <h1>{{address.name}} <span>{{address.m}}/{{address.n}}</span></h1>
            <p>address: <span class="data well">{{address.keys.address}}</span></p>
            <p>public: <span class="data well">{{address.keys.public}}</span></p>
            <p>private: <span class="data well">{{address.keys.private}}</span></p>
            <p>Script: <span class="data well">{{address.asm}}</span></p>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-primary">Create TX</button>
          <button type="button" class="btn btn-primary">Add Party</button>
        </div>
      """
]




