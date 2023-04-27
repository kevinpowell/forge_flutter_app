import 'package:flutter/material.dart';
import 'package:flutter_opengl/flutter_opengl.dart';
import 'dart:developer' as dev;
import 'package:path/path.dart';
import 'dart:ffi' as ffi;

typedef RenderFunc = ffi.Void Function();
typedef dRenderFunc = void Function();

class SoLibrary {
  factory SoLibrary() {
    // make it a singleton
    _instance ??= SoLibrary._();
    return _instance!;
  }

  SoLibrary._() {
    // todo - check for Platform type
    _nativeApiLib = ffi.DynamicLibrary.open(absolute('native/libplot3_flutter.so'));
  }

  static SoLibrary? _instance;

  late ffi.DynamicLibrary _nativeApiLib;
  late final dRenderFunc _renderPlot = _nativeApiLib.lookup<ffi.NativeFunction<RenderFunc>>("render_plot").asFunction(isLeaf: true);
}

class PlotRendererWidget extends StatelessWidget {
  final int width = 400;
  final int height = 300;

  const PlotRendererWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // make a widget that contains an OpenGL surface that other openGL code can render to

    return FutureBuilder<int>(
      // get texture id
      future: OpenGLController().openglPlugin.createSurface(
            width.toInt(),
            height.toInt(),
          ),
      builder: (context, textureId) {
        if (!textureId.hasData || textureId.hasError) {
          return const SizedBox.shrink(); //something went wrong, give back an empty box
        }
        // TODO : build Forge chart object (with child plot)
        // TODO : call chart object render function to render it on our GL surface
        // sort of like this...
        // forge::Chart chart(FG_CHART_3D);
        // chart.setAxesLabelFormat("%3.1f", "%3.1f", "%.2e");
        // chart.setAxesLimits(-1.1f, 1.1f, -1.1f, 1.1f, 0.f, 10.f);
        // chart.setAxesTitles("x-axis", "y-axis", "z-axis");
        // forge::Plot plot3 = chart.plot(ZSIZE, forge::f32);
        // // generate a surface
        // std::vector<float> function;
        // static float t = 0;
        // generateCurve(t, DX, function);
        // GfxHandle* handle;
        // createGLBuffer(&handle, plot3.vertices(), FORGE_VERTEX_BUFFER);
        // /* copy your data into the pixel buffer object exposed by
        //  * forge::Plot class and then proceed to rendering.
        //  * To help the users with copying the data from compute
        //  * memory to display memory, Forge provides copy headers
        //  * along with the library to help with this task
        //  */
        // copyToGLBuffer(handle, (ComputeResourceHandle)function.data(), plot3.verticesSize());
        // ...now do the parts of window_impl.cpp that are needed.
        //  mostly : chart.render(....)
        // note you'll need to instantiate and init the other args to chart.render().
        SoLibrary()._renderPlot();

        // start renderer
        OpenGLController().openglFFI.startThread(); //Now OpenGL will run its rendering loop and update this widget's drawing area
        return SizedBox(
          width: width.toDouble(),
          height: height.toDouble(),
          child: OpenGLTexture(
            id: textureId.data!,
          ),
        );
      },
    );
  }
}
