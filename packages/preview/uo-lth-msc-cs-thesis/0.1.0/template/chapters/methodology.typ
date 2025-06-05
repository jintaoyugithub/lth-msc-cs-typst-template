= Methodology

_This chapater aims to introduce the methodology involved to address the research questions and challenges, including the implementation overview as well as tools and framework used in this project._
#v(15pt)

//== Overview of Project Iterations

== Implementation Overview

The implementation can be broadly divided into two main phases: offline and runtime. We precompute all the required triangle patterns in advance and upload them to GPU memory so that the compute shader can use them later, see Figure 15.

#figure(
  image("figures/pattern.png", width: 100%),
  caption: [
    Pre-computed patterns
  ],
)

During runtime, for each visible triangle from the input coarse mesh, we select a triangle pattern based on various metrics such as a fixed tessellation rate or the distance to the camera. The selected pattern is then applied in the compute shader to generate smaller triangles. If a displacement texture is available, displacement mapping is performed afterward, see Figure 16.

#figure(
  image("figures/realtime.png", width: 100%),
  caption: [
    Short version of real time process
  ],
)

== Tools and Framework

The development of our system is based on several key tools and frameworks. The graphics backend is built on Vulkan with the shading language GLSL. _nvpro_ @nvpro_core from Nvidia is used to fast build Vulkan application and provide several useful utilities, including convince UI framework and profiling tools. The c++ library _tinyobjloader_ @tinyobjloader is used to load models in wavefront format, the open-source _stb_ @stb library is employed for image loading. _ktx2_ @chadwick2021ktx2 is the primarily format of the texture used in this project to reduce GPU memory usage. For graphics debugging, we rely on Nvidia _Nsight_ and _RenderDoc_. The 3D model used in this project was created in ZBrush based on the _Big Guy_ character.


// vulkan graphics backend
//
// glsl as shading language
//
// nvpro frame work: provide fast vulkan application build, profilering tools
//
// c++ package: stb_images, obj loader
//
// typst template is create by teo
//
// 还有提一下里面用到的美术资源
//
// debug tool: nvidia nsight and renderdoc
//
// ktx2 format to save some memory
