
ENTROPY = 0

module.exports =
  get: -> ENTROPY

app = angular.module 'Entropy', []

app.controller 'EntropyCtrl', ['$scope', ($scope) ->

  $scope.close = false
  $scope.done = false
  $scope.max = 100
  $scope.value = 0
  $scope.entropy = 0
  $scope.type = 'info'

  $scope.addEntropy = ($event) =>
    unless $scope.wait
      $scope.entropy = ENTROPY = "#{$scope.entropy}#{$event.pageX}"
      $scope.value = $scope.value + 1 unless $scope.done
      $scope.wait = true
      setTimeout ( -> $scope.wait = false ), 4
      if $scope.value >= $scope.max
        $scope.type = 'success'
        $scope.done = true
]

app.directive 'entropyView', ->
  template: """
  <div class="entropy">
    <div class="wrapper" ng-hide="close">
      <div class="content">
        <h1>Generate Entropy</h1>
        <progressbar max="max" value="value" type="{{type}}">
            <span>{{value}}%</span>
        </progressbar>
        <p>Move your mouse around the screen to generate entropy, for your security.</p>
        <p><button ng-show="done" type="button" class="btn btn-primary" ng-click="close = true">Done</button></p>
      </div>
    </div>
  </div>
  """
