@tool

extends CSGCombiner3D

enum TunnelType { HEMI, HEMI_SMALL, HEMI_TINY, BOX }

@export var type := TunnelType.BOX:
	set(value):
		type = value
		$SurfaceHemi.hide()
		$SurfaceHemiSmall.hide()
		$SurfaceHemiTiny.hide()
		$SurfaceBox.hide()
		match value:
			TunnelType.HEMI:
				$SurfaceHemi.show()
			TunnelType.HEMI_SMALL:
				$SurfaceHemiSmall.show()
			TunnelType.HEMI_TINY:
				$SurfaceHemiTiny.show()
			TunnelType.BOX:
				$SurfaceBox.show()

@export var length := 10.0:
	set(value):
		length = value
		$SurfaceHemi.depth = value
		$SurfaceHemiSmall.depth = value
		$SurfaceHemiTiny.depth = value
		$SurfaceBox.size.z = value
		$SurfaceBox.position.z = -value / 2.0
