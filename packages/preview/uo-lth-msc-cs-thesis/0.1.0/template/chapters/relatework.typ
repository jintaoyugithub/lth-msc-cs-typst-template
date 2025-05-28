= Theory and Related Work

_double check_:
#v(15pt)


== Tessellation

In computer graphics, tessellation[] describes the process of dynamically dividing existing primitives into smaller ones on the GPU, see Figure ?. The primitives are usually triangles or quads, depending on the tessellation algorithm used, for example Catmull-Clack[]. The main advantage of this process is that the GPU can generate a higher density of small tuples in real-time during the rendering phase while only transmitting a coarse mesh which is a model with simplified topology and lower number of primitives counts.  While enriching the detail of the model, improves the visual realism, it also decrease the bandwidth of data transfers between the CPU and the GPU.

! [Illustration: Surface Subdivision Principles and Element Delineation Process]

#figure(
  image("figures/my.png", width: 30%),
  caption: [
    test
  ],
)

演化了很多年

// not related to tessellation
// In contrast to the traditional LOD method, artists need to manually create multiple versions of a model with different polygon counts, which can be switched between in real-time rendering based on distance, viewing angle, or screen size, in order to balance between performance and visual quality. 
//
// ! [Comparison of character models at different LOD levels.]

The widespread use of surface tessellation techniques has also given rise to a new type of LODs system, depending on the different measurements like xxx, gpu can adaptively tessellate and generate necessary smaller primitives on-the-fly during run-time, which has been widely used in procedural generated terrain, ocean or cloth simulation, creating flexibility and scalability to the asset creation process.

#figure(
  image("figures/my.png", width: 30%),
  caption: [
    test
  ],
)

! [Illustration: Schematic application of surface subdivision in dynamic terrain and water surfaces].

// 在cg中的曲面细分describe a process of 在gpu中动态把已有的primitive切割成更小的primitive, 可以是三角形，也可以是quad，depending on你使用的refinement scheme[], 以达到减少cpu-gpu数据传输的同时得到更多的细节，更加真实的模型表示。
//
// ![] show the tessellation theory, 
//
// 由于tessellation的存在，进而衍生出了全新的lod系统。相对于传统的lod系统来说，artist需要在建模软件中创建不同polygon数量，不同精度的模型以满足在real time rendering中根据不同的measurement来选择渲染不同level of details的模型以保证performance。
//
// ![] show the different lod character models
//
// 而基于tessellation, 就使得我们可以only transfer the coarse mesh which (帮我解释一下coarse mesh), and tessellated the primitives, usually are triangles or quads, on the fly in the gpu to generated smaller primitvies to acheive or reproduce the details of the origin geometries.
//
// 这项技术广泛的运用在dynmaic terrain lod，dynamically changed object like ocean or cloth
//
// ![] show tessellation lod usages

== Geometry representation

Geometry representation is the fundamental concept in computer graphics when constructing and processing 3D models. Different model representations in different scenes can have a significant impact in terms of complexity, edibility, and rendering effects. Traditional geometric representations such as polygon, parametric surface, and subdivision surface have been widely used in modeling and rendering. However, with the continuous development of Artificial Intelligence and Machine Learning technologies, new geometric expressions, such as point cloud and neural radiance field, have emerged. 

// Geometry representation is the fundamental concept in Computer Graphics when constructing and processing 3d models? 不同场景下，不同模型的表现方式从复杂度，可编辑性以及渲染效果都有着不同的影响。传统的几何表达方式包括polygon，parametric surface以及subdvision surface，但随着ai和ml技术的不断革新，新的geometry表达方式例如cloud point, neural radiance surface等也随之出现。

=== Topology

拓扑结构在不同的领域定义其实是不一样的，在图形学几何分之中，拓扑结构描述了模型数据的连接和组织关系。而在以polygon为主导的实时渲染领域中，其拓扑结果就是通过点，线和面的组合来描述模型的连接关系, see Figure x.

#figure(
  image("figures/my.png", width: 30%),
  caption: [
    test
  ],
)

![pixar subdivision topology]

在三维建模中，拓扑结构会影响模型的变形行为、细分处理，甚至是光照结果。在细分算法中[]，良好的拓扑结果，减少产生不必要顶点的同时，还能保证细分过程中生成顶点的正确位置和连接关系[catmull-clack]。此外，在游戏领域，拓扑结果还直接影响着动画变形的效果和物理模拟的准确性。

值得注意的是有的时候外表上完全一样的模型，其实背地里可能拥有着完全不同的拓扑结果，see figure X。

#figure(
  image("figures/my.png", width: 35%),
  caption: [
    test
  ],
)

![不同拓扑结构的monkey]

=== Polygon

由于三角形由三个顶点构成一个唯一的最小平面，因此天然避免了四边形可能出现的共面问题，如扭曲或折叠。这一特性使得三角形从计算机图形学诞生之初，就被确立为几何建模和图形渲染中的基础单元，并在随后的几十年中，始终是图形技术发展的核心组成部分。特别是在实时渲染领域，三角形因其数据结构简单、插值结果无歧义以及便于光栅化等优势，成为 GPU 架构中设计的核心图元（primitive）。

#figure(
  image("figures/my.png", width: 25%),
  caption: [
    test
  ],
)

![barycentric coordinates]

在 GPU 中，顶点属性（如法线、UV 坐标等）可以通过重心坐标插值（Barycentric Interpolation）进行计算。具体来说，若某一片元在三角形三个顶点对应的重心系数为a，p，r，而对应的attributes是a，b，c，则该片元的属性值m可通过公式一插值得出

$ s $ 

尽管三角形在实时渲染中占据主导地位，但在影视动画制作与高精度建模行业中，四边形（Quad）同样扮演着不可或缺的角色。由于四边形在构造良好拓扑结构方面具有明显优势，其规则的网格排列便于形成清晰的边缘环线（Edge Loop），这对于角色建模、骨骼绑定以及面部表情动画的控制都至关重要。良好的 Edge Loop 不仅提升了模型的可编辑性，也为后期动画驱动提供了更高的精度与灵活性。

#figure(
  image("figures/my.png", width: 25%),
  caption: [
    test
  ],
)

![edge loop of triangle and quad]

此外，许多经典的细分曲面算法，如 Catmull-Clark 算法，正是以四边形网格为基础进行递归细分与平滑处理的。在这些算法中，四边形网格能够更好地维持表面连续性与光滑性，使得建模师在创建高质量模型时能够获得更理想的视觉与拓扑效果。


// - subdivsion surfaces
//
// 相比于parametric surface这种有函数构成的显示的数学表达方式，subdivision surface由于是以coarse mesh加上repeatly perform subdivision algo近似达到光滑曲面的过程，尽管不是所有的算法都能达到parametric surface那般c2的连续性，但是更灵活的随即拓扑结构
//
// 更加直观
// 一样不俗的光滑表面的表现
//
// 通过使用peacewise parametric patch的方法使得subdivision surface可以应对arbitrary topology
//
// peacewise parametric patch
//
// refine polygon mesh, math tool to define the underlying smooth surface
//
// a coarse + subdivision algo. e.g. catmull-clack, loop
//
// limit surface provide high order continuity, which make the surface more smooth, subdivsion algo [] will modified the topology of the coarse mesh, which cause 在实时动画领域，由于拓扑结构的不断改变，会造成顶点数据的计算量极具增大，并且对于tongyilevel的tessellation，subdivision往往需要更多的三角形来

== Compute shader

To fulfill demand for arbitrary computational task, compute shader as a shader stage, differ from the other shader stage as it's not part of the traditional rendering pipeline, was introduced in DirectX11 and OpenGL 4.3 to execute massively parallel, general-purpose computation on the gpu. Unlike languages designed for gpgpu programming such as OpenCL[] and CUDA[], compute shaders naturally benefit from tight integration with graphics APIs, allowing them to directly utilize graphics-related functions

// To fulfill demand for arbitrary computational task, compute shader as a shader stage, differ from the other shader stage as it's not part of the traditional rendering pipeline, was introduced in DirectX11 and OpenGL 4.3 to execute massively parallel, general-purpose computation on the gpu. 与opencl和cuda这种专为gpgpu programming设计的语言不通，compute shader has the nature advantages of 跟图形api合作并调用他们的函数。

=== Pipeline and Architecture

From figure x, it can be seen that the compute shader has a very subtle relationship with the other stages in the overall vulkan graphic pipeline. The separate pipeline architecture means that the compute shader is able to operate independently of the traditional rendering pipeline, which provides flexibility but also creates a situation where While this provides flexibility, it also results in additional cost being necessary for the compute shader to interact with the traditional rendering pipeline, which is a limitation of this article and will be explained in detail in section xxx.

! [vulkan graphics pipeline]

During the execution of the Compute Shader, the execution model is defined by **Work Groups** and Invocations**, which control how tasks are scheduled in parallel on the GPU. Each workgroup consists of multiple threads, and each thread is an Invocation; both the workgroup and the number of threads define the layout of the computational tasks in a three-dimensional way, and the determination of the dimentions is controlled by the dimention of the data you're put in

#figure(
  image("figures/my.png", width: 30%),
  caption: [
    test
  ],
)

![execution model from vulkan]

The number of workgroups and the number of threads in each group determine the total number of calls to the Compute Shader. For example, dispatching work groups with dimention of (8,1,1) including (64,1,1) invocations inside one work group will invoke the compute shader 8x1x1x64x1x1(make it into equation?) = 512 times.


// ![vulkan graphics pipeline]
//
// From figure x，可以看出compute shader在整个vulkan graphic pipeline中与其他stage的关系非常微妙，单独的管线架构意味着compute shader是可以脱离传统渲染管线而自主运作的，在提供了灵活性的同时，也造成了compute shader与传统的渲染管线交互的时候，additional cost is necessary，这也成为了本篇文章中的一个limitation，我们之后将会在xxx章节中详细解释。
//
// 在 Compute Shader 的执行过程中，**Work Group（工作组）与Invocation（线程调用）**共同定义了其执行模型，它们控制了任务在 GPU 上的并行调度方式。每个工作组由多个线程组成，而每个线程就是一次 Invocation。无论是工作组还是线程数量，都可以通过三维方式定义计算任务的布局，而the determination of the dimentions is control by the dimention of the data you're put in
//
// ![execution model from vulkan]
//
// 工作组的数量与每组中的线程数决定了 Compute Shader 的总调用次数。举例来说, dispatching work groups with dimention of (8,1,1) including (64,1,1) invocation inside one work group

=== Data Access and Manipulation

In order to enable Compute Shaders to read and write data flexibly, modern graphics APIs provide mechanisms such as Shader Storage Buffer Object (SSBO) and Storage Image. SSBO, as a general-purpose buffer object, is commonly used to store and manipulate structured data, while storage image is is used more for accessing image resources and is applicable to various tasks related to image processing. Through these two approaches, a compute shader can efficiently interact with internal and external data to support complex computation processes.

Typically, a compute shader can access data with a thread id, but during parallel execution, multiple threads may access the same memory address at the same time, especially when reading and writing to shared buffers. To avoid data contention without introducing expensive locking mechanisms, **Atomic operations ensure that only one thread can read or write to a target address at a given time, thus avoiding data conflicts while ensuring parallelism.

// 为了使 Compute Shader 能够灵活地读写数据，现代图形 API 提供了如 Shader Storage Buffer Object（SSBO）和 Storage Image 等机制。SSBO作为一种通用的缓冲区对象，常用语存储和操作结构化数据，而storage image则更多用于访问图像资源，适用与各种与图像处理相关的任务。通过这两种方式，Compute Shader 可以高效地与内外部数据进行交互，支撑复杂的计算流程。

// 通常的，compute shader可以用thread的id来访问数据，但是在并行执行过程中，多个线程可能同时访问同一个内存地址，尤其是在对共享缓冲区进行读写时。为了避免数据竞争而不引入昂贵的锁机制，**原子操作（Atomic Operation）**被引入。原子操作确保在某一时刻只有一个线程可以对目标地址进行读写操作，从而在保证并行性的同时避免数据冲突。

== Displacement mapping

Displacement Mapping @cook1984shade was originally a technique used to generate natural textures, and later it gained widespread application in computer graphics. As an alternative way to restore the details of the original model during real-time rendering, displacement mapping samples pre-baked or mathematically calculated vertex displacement data to modify the positions of the surface vertices of an object. 

This allows for more precise detail by actually changing the shape of the object's surface, instead of just cheating the surface normals with normal maps do. Because the surface shape is really modified, displacement mapping also naturally fixes problems like self-shadowing and self-occlusion that normal or bump maps can’t handle well.

#figure(
  image("figures/my.png", width: 30%),
  caption: [
    pipeline
  ],
)

Scalar Displacement and Vector Displacement are common in most use cases where the former has a relatively simple data format, using a single-channel grayscale map to describe the displacement magnitude of each point along a certain direction—usually the model’s normal direction. It is commonly used on models with simple topology, such as terrain generation see figure x. The latter is a more advanced representation. It records the displacement direction and magnitude of vertices in 3D space using the three RGB channels, allowing displacement in any direction: normal, tangent, or even opposite directions. Therefore, it is better suited for complex surface deformations, see figure. However, the increased data size leads to higher storage and bandwidth costs, which limits its application.


#figure(
  image("figures/my.png", width: 30%),
  caption: [
    pipeline
  ],
)

![世界地图的height map, 以及运用在一个quad上的效果]

![vector displacement的图片以及displace后的效果]

// Displacement Mapping @cook1984shade 最初作为一种生成自然纹理的技术，后来在计算机图形学中得到了广泛应用。as an alternative way 在实时渲染时还原原始模型的细节，displacement mapping通过采样事先baked好的或者是通过数学计算得出的顶点位移数据, 改变物体表面的顶点位置，从而达到更精确的模拟细节，而不是仅仅只是改变物体表面的法线，比如说通过发现贴图，来影响光照的效果。除此之外，由于真正的改变了物体表面的形状, 因此天然的解决了从前normal map[]或者bump map[]所造成的self occlusion以及self shadow的问题。
//
// 从数据表达的角度来看，Displacement Mapping 通常可以分为两类：标量位移（Scalar Displacement）与向量位移（Vector Displacement）。标量位移是一种相对基础的形式，它通过一张灰度贴图（通常被称为 height map）来表示表面上各个点沿某一方向的位移幅度。这个方向一般为表面法线方向，或在某些特定实现中固定为世界空间或模型空间中的一个轴向（例如 Y 轴）。由于其数据结构简单，计算效率较高，标量位移常用于地形渲染、建筑立面的浮雕细节等中。
//
// 与之相比，向量位移则是一种更高级的表示形式。它使用 RGB 三个通道分别编码顶点在三维空间中的位移方向和幅度，因此能够表达任意方向上的几何偏移。这种方式不仅可以沿法线方向推进顶点，还可以在切线方向、甚至反方向上进行复杂的表面形变。向量位移尤其适合还原高精度雕刻模型的细节，许多艺术家在使用zbrush建模时，可以将之前建模与雕刻的局部复杂的结构用vector displacement texture保存，并在其他模型上复用。
//
// 由于向量置换贴图需要使用三通道数据来精确编码顶点在三维空间中的偏移向量，导致其数据量显著增加，存储和带宽开销较大。在实时渲染环境中，这种高数据密度不仅对显存和纹理采样带来了较高负担, 从而限制了其在实时渲染了领域的广泛应用, 从而限制了其在实时渲染了领域的广泛应用


== Related work

//去抄real time rendering with hw tess的realted work

=== Prior Refinement Schemes

// 在hw tess问世之前，[]就提出了一种利用vertex shader来instantiate triangle pattern的做法，本文中许多概念也是从它的文章中借鉴来的。他们也提前在cpu保存了不同tessellation factor所需的pattern在一个三维数组中，并将这些数据上传到gpu memory让vertex shader的runtime的时候，可以直接对不同的pattern中的顶点进行空间变换，达到生成更多primitive的目的。

// Before Hardware Tessellation technique came out, [] proposed a practice of using a vertex shader to instantiate triangle patterns, and many of the concepts in this article were borrowed from its article. They also saved the required patterns for different tessellation factors in a 3D array at the cpu in advance, and uploaded these data to the gpu memory to allow the vertex shader to directly perform spatial transformations on vertices in different patterns to achieve the generation of more primitive.

// 在之后的文章中[]，他们还对先前uniform的pattern进行了改进，更大限度地提升了此方法的灵活性和拓展性。但是由于该方法是基于vertex shader的，vertex shader之间是没办法互相通信，一次也只能处理一个vertex，原文中也并没有给出实现细节，所以并不知道在vertex shader中vertices of coarse triangle和refinepattern中的顶点如何对应的。而且vertex shader本身重复调用的问题也会给该方法带来一些性能影响。

// In a later article [], they also improved the previous uniform pattern to increase the flexibility and extensibility of this method. However, since this method is based on vertex shaders, there is no way for vertex shaders to communicate with each other, and only one vertex can be processed at a time. The original article doesn't give the implementation details, so it's not clear how the coarse triangle and pattern are mapped. 

// 后来更多的gpu refinement schemes被提出，例如许多像[cuda tessellation]基于gpgpu的方法，通过为
//
// 还有phong tessellation，pn trianlge tessellation

// 随着 GPGPU 编程模型的发展，越来越多基于通用 GPU 计算（如 CUDA）的 refinement 技术被提出。例如使用 CUDA 实现了对高阶曲面（如 Bézier Patch 和 PN Triangle）的实时adaptive tessellation。此外，还有一些基于片段插值的改进方法，如 Phong Tessellation 4 和 PN-Triangle Tessellation 5，它们通过对已有顶点进行插值与曲率拟合，生成更为平滑的细分曲面。这类方法主要目标是提升视觉质量，虽然并不直接增加新的拓扑结构，但在视觉效果上与传统几何细分相似。

// With the development of the GPGPU programming model, an increasing number of refinement techniques have been proposed. For example, real-time adaptive tessellation of higher-order surfaces like Bézier patches and PN triangles has been implemented using CUDA. 
//
// Additionally, there are some fragment interpolation-based refinement methods, such as Phong Tessellation and PN-Triangle Tessellation, which generate smoother subdivided surfaces by interpolating existing vertices and fitting curvature. These methods primarily aim to improve visual quality. Although they do not directly increase new topological structures, their visual effects closely resemble those of traditional geometric subdivision.


=== Hardware Tessellation

为了解决cpu上实现dynamic tessellation造成的cpu-gpu之间数据传输的瓶颈，随着xbox360[]和direct3d11[]的发布，现在gpu渲染管线开始引入hardware tessellation技术，see Figure X, 并以此奠定了一种全新的dynamic lod system的发展。

#figure(
  image("figures/my.png", width: 30%),
  caption: [
    pipeline
  ],
)

hw tess拥有更加灵活的tess对象，在渲染管线中，这些primitive被抽象成patch，it's a collection of vertices, 3 vertices represent triangle patch, 4 represent quad patch。它通过控制不同边的细分成都来达成adaptive的效果，并切支持带有小数的细分factor以及不同的spacing策略来达到跟细致的细分操作。

hw tess通过hull shader and domain shader这样的可编程shader，开放了一定的灵活性给编程人员，在有着一定灵活性与拓展性的前提下，充分利用硬件对真正细分操作的加速计算，使其保持良好的性能优势。

// - fix tessellation function, 很快但是缺少灵活性
// - 在patch内部产生不可预测的duplicate vertices，*这里需要资料支持*
// - hardcode在传统渲染管线中，无法避免的会产生传统渲染管线中其他part带来的问题, 比如说，vertex shader对同一个顶点的重复调用，
// hw tessellation

尽管hw极大提升了对高质量几何模型细节的实时处理效率，其本身仍存在一些不可忽略的局限性。比如，由于hw tess是针对每个patch进行细分操作的，这些patch之间其实并不共享拓扑信息，所以就会导致不可避免在相邻三角形的shared edges上生成重复的三角形，加上hw tess的输出是直接进去渲染管线之后的阶段的，并没有写入gpu的内存，真正执行tessellation操作的是gpu管线中一个不可编程的阶段，这就导致想要人为干预介绍重复的顶点是很困难的

// 此外，当前硬件细分器的实现也存在的效率瓶颈，由于hardware tessellation与传统渲染管线整合在一起的，它难免会受到遵循这样的阶段划分带来的影响。并且[一个post]patch内部，tessellator有可能对同一个顶点调用多次的tessellation, 虽然说最后结果是一眼的，但是这样仍然增加了许多计算冗余。

=== Nanite

近年来，随着Unreal Engine 5的发布，Epic Games 推出的 Nanite 系统提出了一种不同于传统曲面细分（tessellation）的几何细节管理方案。相比于传统的refinement scheme，使用一个coarse mesh然后在gpu不断生成更多的三角形来还原细节，nanite将原本的高精度模型分割成拥有不同细节层的的cluster，即a collection of a certain amount of triangle, 在渲染时，动态的加载不同细节层级的几何数据。

尽管 Nanite 在静态模型场景中表现卓越，极大限度的保留模型细节的同时，通过高效的drawcall以及gpu调度机制实现了极高的渲染效率，但是其仍存在一些局限。例如，原始 Nanite 系统对动态变化的几何结构（如蒙皮动画、程序性变形等）支持不够完善，原因在于没有coarse mesh的支持，动画计算涉及到的顶点计算量太过庞大因为nanite是直接使用高精度模型中的某块三角形。

=== Micro-Mesh and Mega Geometry

与之前提到的refinement pattern不同的是，Micro mesh follows a completely different approach to save GPU memory storage and rendering cost by converting a mesh to a list of compressed micro-meshes, which are stored in compressed barycentric coordinates and compile into a binary format. 

#figure(
  image("figures/my.png", width: 30%),
  caption: [
    test
  ],
)

在gpu端，nvidia的现代gpu架构[白皮书]加入了全新的geometry engine，能够为micro mesh提供原生的硬件加速支持，使得在实时渲染时，micro trianlge的数据可以高效的展开和traversal。

然而由于micro mesh的构造涉及了很多复杂的预处理，比如确定tessellation rate，通过对每个micro vertex发射射线从而生成detail的vertex offset信息，再有构建加速结构，压缩生成的数据等等，使得micro mesh并非用于实时编辑或动画场景，目前更多用于离线渲染或高质量 ray tracing 任务。

// 2021年，nvidia introduce micro triangle
//
// it's offline
//
// first time: ray tracing with displacement mapping
//
// cluster based acc structure, but they also provide a way to see a new software tessellation solutions
//
// it's mesh shader only, some platform doesn't support mesh shader or not full version of mesh shader
//
// comes with several features, one of them is cluster based tessellation

// 相比于micro triangle只关心几何数据压缩的技术，Nvidia在2025年2月提出mega geometry更多为为了提升传统光线追中中的加速结构[]。但本文只关心mega geometry中涉及细分和还原模型细节的技术。它同样借鉴了[]中adaptive refine pattern的概念，利用task shader和mesh shader在gpu中实现高效的cluster based tessellation, 

相比于 Micro Triangle 仅关注几何数据压缩与存储效率，NVIDIA 于 2025 年 2 月提出的 Mega Geometry 框架，更主要的目标在于提升传统光线追踪流程中的加速结构构建效率与渲染性能1。然而，本文关注的是该框架中与 几何细分和模型细节还原 相关的技术部分。

Mega Geometry同样借鉴了早期 GPU-based refinement 方法中的 adaptive refinement pattern 概念[]，采用 cluster-based 的结构进行几何管理，并通过 Task Shader 与 Mesh Shader 的组合在 GPU 上实现高效的动态细分。但其实本质上tessellation还是以triangle来执行的，同样会造成shared edge上的重复顶点.

