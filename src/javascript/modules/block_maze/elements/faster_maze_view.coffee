React = require 'react'
React3 = require 'react-three-renderer'
THREE = Three = require 'three'

pi=Math.PI
{euler,vec3,quat, convertCannonVec3, convertCannonQuat} = require '../../../lib/three_helpers'

EntitySearch = require '../../../lib/ecs/entity_search'
C = require '../components'
T = C.Types

SceneWrapper = require './scene_wrapper'

Objects = require '../objects'

LookCamera = (props) ->
  {cameraInfo,lookAt} = props
  <perspectiveCamera
    name={cameraInfo.name}
    position={cameraInfo.position}
    fov={75}
    aspect={cameraInfo.aspect}
    near={0.1}
    far={1000}
    lookAt={lookAt}
  />

DevCamera = (props) ->
  {cameraInfo,aspect} = props
  <group 
    rotation={euler(0,cameraInfo.pan,0)}
    position={cameraInfo.position}
  >
    <perspectiveCamera
      name={cameraInfo.name}
      rotation={euler(cameraInfo.tilt,0,0)}
      fov={75}
      aspect={aspect}
      near={0.1}
      far={1000}
    />
  </group>

FollowCamera = (props) ->
  {name,aspect,cameraEntity} = props

  cam = cameraEntity.get(T.FollowCamera)
  lookAt = convertCannonVec3(cam.lookAt)

  camLoc = cameraEntity.get(T.Location)
  pos = convertCannonVec3(camLoc.position)

  <perspectiveCamera
    position={pos}
    name={name}
    fov={75}
    aspect={aspect}
    near={0.1}
    far={1000}
    lookAt={lookAt}
  />


FOG = new Three.Fog(0x001525, 10, 40)

MyDirLight = (props) ->
  d = 20
  <directionalLight
    color={0xffffff}
    intensity={1.75}

    castShadow

    shadowMapWidth={1024}
    shadowMapHeight={1024}

    shadowCameraLeft={-d}
    shadowCameraRight={d}
    shadowCameraTop={d}
    shadowCameraBottom={-d}

    shadowCameraFar={3 * d}
    shadowCameraNear={d}

    position={props.lightPosition}
    lookAt={props.lightTarget}
  />

CameraSearcher = EntitySearch.prepare([T.FollowCamera])
getCameraEntity = (estore) ->
  CameraSearcher.singleEntity(estore)

PhysicalSearcher = EntitySearch.prepare([T.Physical,T.Location])

LIGHT_POS = vec3(20, 20, 20) # magic number d
LIGHT_TARGET = vec3(0, 0, 0)

MazeView = React.createClass
  displayName: 'FasterMazeView'

  getInitialState: ->
    {
      width: @props.width
      height: @props.height
    }
  
  # Called ONCE just before initial render.
  componentWillMount: ->

  # Called ONCE just after initial render. DOM refs of chilcren are available.
  componentDidMount: ->
    @sceneWrapper = new SceneWrapper(canvas: @canvas, width: @state.width, height: @state.height)


  # Called once, just before removal from DOM.
  componentWillUnmount: ->

  componentWillReceiveProps: (nextProps) ->
    if nextProps.width != @state.width or nextProps.height != @state.height
      @setState {
        width: nextProps.width
        height: nextProps.height
      }

    @sceneWrapper.updateAndRender(nextProps.estore, nextProps.width, nextProps.height)

  # Determine if render and DOM flushing should occur.
  # Not called on initial render.
  shouldComponentUpdate: (nextProps, nextState) ->
    (nextState.width != @state.width) or (nextState.height != @state.height)

  # Called just before render assuming shouldComponentUpdate returned true.
  # DO NOT CALL setState in here.
  # Not called on initial render.
  componentWillUpdate: (nextProps, nextState) ->

  # Called after render and DOM changes have been flushed
  # Not called on initial render.
  componentDidUpdate: (prevProps, prevState) ->

  render: ->
    <canvas 
      width={@state.width} 
      height={@state.height} 
      style={width:@state.width, height:@state.height} 

      ref={(ref) => @canvas = ref} 
    />

module.exports = MazeView

