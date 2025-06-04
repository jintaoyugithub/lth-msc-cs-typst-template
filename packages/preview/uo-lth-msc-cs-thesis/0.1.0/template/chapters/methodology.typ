= Methodology

_This chapater aims to introduce the methodology involved to address the research questions and challenges, including the literature study, implementation overview as well as tools and framework used._
#v(15pt)

== Literature Study 

todo: move to chapater 2

The literature study has been carried out throughout the work of this project, most of the references were found through Google Scholar and the ACM Digital Library. _compute shader tessellation_, _gpgpu tessellation_ are the main focus of the initial research. 

Later, inspired by Mega Geometry @RTXMG and related techniques @boubekeur2005generic @boubekeur2008flexible, the direction of the study was then shifted to its cluster based tessellation technique, the subsequent exploration focused on _gpu generic refinement schemes_, _mesh shader pipeline_, and _micro-triangle_. In addition, to deepen our understanding of the geometry representation, key words _subdivision surface_ and _polygonal representations_ are used. Finally to enrich the visual quality, we also studied techniques such as _subdivision surface approximation_ and _displacement mapping_.

// literatures studied贯穿了整个项目，大部分的文献资料都来自于google scolar和acm digital libtary。compute shader tessellation, gpgpu tessellation are used for最早的研究，之后由于收到了Nvidia在2025年2月介绍的mega geometry的启发,之后的研究就开始围绕围绕mega geometry展开的with the key word of gpu genric refinement scheme, mesh shader pipeline, micro triangle[have many refs here]; In addition, to have a further deep understanding of geometry representation, subdivision surface, polygon representation, xxx key words are used. Finaly, 为了得到更好的visual quality， we also explore subd approximation, displacement mapping

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

The development of our system is based on several key tools and frameworks. The graphics backend is built on Vulkan with the shading language GLSL. _nvpro_ from Nvidia is used to fast build Vulkan application and provide several useful utilities, including convince UI framework and profiling tools. The c++ library _tinyobjloader_ is used to load models in wavefront format, the open-source _stb_ library is employed for image loading. _ktx2_ is the primarily format of the texture used in this project to reduce GPU memory usage. For graphics debugging, we rely on Nvidia _Nsight_ and _RenderDoc_. The 3D model used in this project was created in ZBrush based on the _Big Guy_ character[].


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
