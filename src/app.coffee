
Backbone = require('backbone')



class Address extends Backbone.Model
  initialize: ({@name, @m, @n} ={})->
    @genKeys()
    @set( 'name', @get('name') or 'Untitled' )
    @set( 'm', @get('m') or 1 )
    @set( 'n', @get('n') or 1 )
    @set( 'txs', @get('txs') or 0 )

  genKeys: ->
    console.log 'gen keys'
    addr = new Bitcoin.Address( Bitcoin.Address.decodeString('1KbZMsBkwgC9Tygh86wbKrFeqPDLNW2rde') )
    @set 'keys',
      private: "05#{ Math.random() * 999999 }"
      public: addr.toString()

class AddressCollection extends Backbone.Collection
  model: Address

addresses = window.addresses = (new AddressCollection( [ new Address( name: 'Test' ) ] )).toJSON()
console.log addresses


app = angular.module 'multiparty', ['ui.bootstrap', 'ngTouch']

app.controller 'AddressesCtrl', ['$scope', ($scope) ->
  $scope.addresses = addresses
  $scope.add = (address) ->
    $scope.addresses.push( address )

]

app.controller 'CreateNewCtrl', ['$scope', '$modal', ($scope, $modal) ->
  CreateNewInstanceCtrl = ($scope, $modalInstance) ->

    $scope.addressModel = new Address( name: 'Untitled' )
    $scope.address = $scope.addressModel.toJSON()

    $scope.ok = ->
      console.log 'ok', $scope.address, $scope.$parent, addresses
      addresses.push $scope.address
      $modalInstance.close()

    $scope.cancel = (x) ->
      console.log $scope, x
      # $modalInstance.dismiss('cancel')

    $scope.gen = ->
      $scope.addressModel.genKeys()
      $scope.address = $scope.addressModel.toJSON()


  $scope.open = (size) ->
    modal = $modal.open
      templateUrl: '/create_new.html'
      controller: CreateNewInstanceCtrl
      size: size
]





app.controller 'AddressCtrl', ['$scope', '$modal', ($scope, $modal) ->
  AddressInstanceCtrl = ($scope, $modalInstance, address) ->
    $scope.address = address 
    console.log 'address instance ctrl', $scope, $modalInstance, address
    $scope.back = ->
      $modalInstance.dismiss('cancel')

  $scope.show = (address) ->
    console.log address, $scope
    modal = $modal.open
      templateUrl: '/address.html'
      controller: AddressInstanceCtrl
      resolve:
        address: -> address
]




app.controller 'EntropyCtrl', ['$scope', ($scope) ->
  $scope.clse = false
  $scope.done = false
  $scope.max = 100
  $scope.value = 0
  $scope.entropy = 0
  $scope.type = 'info'

  $scope.addEntropy = ($event) =>
    unless $scope.done or $scope.wait
      $scope.entropy = $scope.entropy + $event.pageX
      $scope.value = $scope.value + 1
      $scope.wait = true
      setTimeout ( -> $scope.wait = false ), 4
      if $scope.value >= 100
        $scope.type = 'success'
        $scope.done = true
]