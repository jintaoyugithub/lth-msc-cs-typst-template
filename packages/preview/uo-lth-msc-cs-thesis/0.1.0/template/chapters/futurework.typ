= Limitation and Future work

_This chapter discuss the challenges and issues we meet throught out the whore precess period. We also outlined several possible solution or related research for the furture work_
#v(15pt)

== Data Optimization

// 由于gpu不像主机，它的内存是非常有限的，举例一些厂商的gpu配置，nvidia和amd。并且由于compute shader没办法必须把生成的数据写回ssbo，完成与传统渲染管线的通信. 我们必须压缩部分数据，以介绍内存的footprint，尤其是使用pattern生成新的primitives 的顶点数据，位置，法线，uv等等。

// 与主机系统相比，GPU 的可用内存资源相对有限。例如，常见的消费级显卡如 NVIDIA RTX 3060 提供约 12GB 显存，而部分 AMD 显卡如 RX 6700 XT 则配备 12GB 或更少的显存。在这种受限的内存环境下，任何冗余的数据存储都会对系统性能产生负面影响。
//
// 此外，在基于 Compute Shader 的渲染流程中，由于其与传统图形渲染管线之间缺乏直接的数据通路，所有生成的中间结果必须显式地写入到gpu内存中 因此，为了降低内存占用并提升运行效率，我们必须对一部分中间数据进行压缩处理。特别是在利用 pattern 生成新的图元（Primitive）过程中，包括顶点位置、法线、纹理坐标（UV）等信息在内的数据都应尽可能压缩存储，以减少整体内存 footprint。

GPUs have relatively limited memory resources available compared to host systems. For example, common consumer graphics cards such as the NVIDIA RTX 3060 provide approximately 12GB of video memory, while some AMD cards such as the RX 6700 XT come with 12GB or less. In this memory-constrained environment, any redundant data storage can negatively impact system performance.

In order to minimize the memory footprint cause by the lack of a direct data path between compute shader pipeline and traditional pipeline and increase the efficiency of the operation, a portion of the intermediate data must be compressed. Especially in the process of generating new primitives using pattern, the data including vertex positions, normals, texture coordinates (UV) and other information should be compressed and stored as much as possible in order to reduce the overall memory footprint.

// 虽然前面提到我们只存储uv，但是每个u and v还是分别用4 byte的float类型存储，i.e. 对于每个顶点都会占用到8bytes, 而如果我们使用32 bits，即4 byte，16 bit 存储u， 16 bit 存储v，这样就能省下来百分之50的内存开销, same for the triangle index, 但对于位数的选择则depending on最大的pattern长生的三角形数量，数量少的话每个index分配8bit就可以，多的话可以考虑16bit（我该在哪里插入这个想法是来自mega geometry) 同理对于在compute shader中使用pattern生成的数据，如顶点，法线等，一样同样可以用类似的方式对其进行高效的压缩，毕竟shader是很擅长进行大规模的简单计算的。
//
// 由于pattern的对称性，我们甚至可以只存储一般的顶点数据，另外一半完全可以通过计算获得。

// 尽管前文提到我们仅存储每个顶点的 barycentric 坐标中的u和v，但目前它们各自仍以 32 位浮点数（float）存储，即每个顶点占用 8 字节。为了进一步整合他们对内存的占用，我们可以将 v 分别编码为 16 位整数，组合为一个 32 位（4 字节）数据结构，从而将每个顶点的内存开销减半。同样地，对于三角形索引的存储也可以采用不同的位宽。具体选择取决于单个 pattern 中生成的三角形数量：当三角形数量较少时，可将每个索引压缩为 8 位整数；而对于复杂的 pattern，则可以选择 16 位以保持表达能力。这种压缩策略参考了 Mega-Geometry 中的其cluster based tessellation特性的做法
//
// 此外，在 Compute Shader 中利用 pattern 动态生成的顶点数据（如位置、法线、UV 等）也可以采用类似压缩方式进行高效存储与重构。由于 Shader 擅长大规模并行的简单计算，这类压缩与解压过程对性能的影响极小，却能显著降低显存占用，尤其适用于受限资源场景中的实时渲染任务。并且得益于 pattern 的高度对称性，我们甚至无需完整存储所有顶点数据，仅需保留一半顶点的属性信息，另一半则可以通过对称映射或简单计算直接还原，从而进一步压缩数据体积，减少存储压力。

Although it was mentioned earlier that we only store u and v in the barycentric coordinates of each vertex, they are currently each still stored as 32-bit floats, which means that they take up 8 bytes per vertex. To further consolidate their memory footprint, we can encode v as 16-bit integers respectively, combining them into a single 32-bit, i.e. 4 bytes data structure, thus halving the memory overhead per vertex. 

Similarly, different bit-widths can be used for the storage of triangle indices. The choice depends on the number of triangles generated in a single pattern: when the number of triangles is small, each index can be compressed to an 8-bit integer; for complex patterns, 16 bits can be chosen to maintain expressiveness. This compression strategy is based on Mega-Geometry's cluster based tessellation feature[].

In Compute Shader, the vertex attributes (position, normal, UV, etc.) generated dynamically by pattern can be restored in a similar compressed way. Since the Shader specializes in parallel computation, compression and decompression have minimal impact on performance and significantly reduce the graphics memory usage. Based on the symmetry of the pattern, only half of the vertex attributes need to be stored, and the other half can be restored by symmetric computation, which further reduces the size of the data.

== Adaptive Patterns

// 目前为止由于使用到的pattern都是uniform的，即三角形三边使用相同的细分等级。这在实际项目中使用该技术存在着很多的瓶颈以及视觉flaw，
//
// 使用全局uniform tess虽然可以解决t-junction造成的crack，但是这个就和游戏中常见discreat lod做法相似， 
//
// 不可避免的crack问题
//
// 最直接的办法，就是保证shared edge with一样的tess rate，这可以通过一个简单的compute shader就能做到，相对复杂一点的，可以用[strugar, 2009]，一种camera based的approach来remove T-junction
//
//
// 除了视觉效果上的问题，对于渲染效率上来说，uniform pattern针对同一种metric会产生很多不必要的顶点, 就那distance to camera来举例，

//![在针对不同曲率所生成的顶点问题 uniform vs adaptive] x

//---

// 目前我们所使用的 pattern 均为 uniform 模式，即对三角形的三条边施加相同的细分等级。这种方式虽然实现简单，并且在一定程度上可以通过统一的 tessellation rate 避免 T-junction 所造成的裂缝问题，但它在实际应用中仍存在诸多限制。
//
// 从渲染效率角度来看, 不同区域往往具有不同的几何复杂度或视角重要性。uniform tessellation 与游戏中常见的 discrete LOD 方法类似，无法根据几何复杂度或视角差异灵活调整每个区域细分密度，从而引入大量冗余顶点。以“到摄像机距离”为例，在距离较远的区域使用与近处相同的 tessellation 密度显然是不必要的，这将导致大量的顶点被浪费在视觉贡献很低的区域，极大影响了 GPU 的效率利用率。相比于基于曲率或视角的 adaptive pattern，uniform 模式会在平坦区域或远离视角的区域生成过多无效顶点，从而增加了不必要的渲染和内存开销。see figure X.

The patterns we have used so far are uniform patterns, i.e., the same tessellation rate is applied to all three sides of the triangle. Although this approach is simple to implement and to some extent can avoid the crack problem caused by T-junction by uniform tessellation rate, it still has many limitations in practical application.

From the perspective of rendering efficiency, different regions often have different geometric complexity or viewpoint importance. Uniform tessellation is similar to the common discrete LOD method in games, which is unable to flexibly adjust the tessellation density of each region according to the difference in geometric complexity or viewpoint, thus introducing a large number of redundant vertices. Compared to adaptive patterns based on curvature or viewing angle, uniform patterns generate too many invalid vertices in flat areas or areas far away from the viewing angle, adding unnecessary rendering and memory overhead. //see Figure X.

// Taking “distance to camera” as an example, it is obviously unnecessary to use the same tessellation density in the farther region as in the nearer region, which will result in a large number of vertices being wasted in the region with low visual contribution. Compared to adaptive patterns based on curvature or viewing angle, uniform patterns generate too many invalid vertices in flat areas or areas far away from the viewing angle, adding unnecessary rendering and memory overhead. see figure X.
//
// ![]
// ![differenct curvature models in uniform pattern and ]

//从视觉效果上来看，因而在不同 tessellation rate 相邻时，容易出现裂缝（crack）问题。最直接的解决方法是确保共享边上的两个三角形使用相同的细分等级，这可以通过一个简单的 compute shader 实现。如需更细致的控制，也可以采用 [Strugar 2009] 提出的基于 camera 视角的动态调整方法，以进一步减少 T-junction。

//可以多写一点

== Generic Vertices Deduplication

// 根据我有限的研究与调查，我发现不管是在最新的mega geometry中，还是稍微早一些的gpu tessellation[]，甚至是hardware tessellation，他们都不可避免的会在shared edge上生成重复的顶点，因为不论是稍微前沿一些的技术还是hardware tessellation他们都是以single triangle or quad作为tessellation的对象，并没有考虑整体的拓扑信息. 这就造成了原本连续的三角形突然间就变成了两个separated的三角形，with overlapping vertices on their shared edges, see Figure X. 

Based on my limited research and investigation, I found that no matter in the latest mega geometry, or slightly earlier gpu tessellation[], or even hardware tessellation, they will inevitably generate duplicate vertices on the shared edge, because they are single triangle or quad as the object of tessellation, and do not consider the overall topological information. This results in a adjacent triangle suddenly becoming two separated triangles, with overlapping vertices on their shared edges, see Figure 43. 


#figure(
  image("figures/ad2sep.svg", width: 90%),
  caption: [
    Adjacent triangles(left), Separated triangles(right)
  ],
)

//![overlap vertices adjacent -> separated]

// 而这也是导致我在重新计算normal的时候，会造成原本我们希望相邻三角形的face normal会作用在同一个顶点上，但是由于重复顶点的原因，现在face normal只会作用在当前构成该三角形的三个顶点上，see Figure X，使得最终的三角形内部的法线插值不够平滑，更坏的是，如果模型的curvature过大，那么两个相邻的三角形则会产生相聚较大的法线朝向，此时这两个三角形的shared edge就会开始争夺这条边的渲染权利，因为他们看似是一条边，但其实是不同的但是overlapped的顶点组成的,see Figure X

That's why when I recalculate the normal, it will cause the face normals of adjacent triangles contribute to the same shared vertex to ensure smooth normal interpolation now only affects the three vertices explicitly forming the current triangle due to the presence of duplicated vertices, each face normal, see Figure 44, which will make resulting normals look flat, see Figure X.


#figure(
  image("figures/leftaccu.svg", width: 90%),
  caption: [
    Triangles involved normal accumulation before tessellation(left) and after tessellation(right)
  ],
)

//![overlapped normal accum]

//![flat vs smooth]

If the curvature of the model is too large, then two neighboring triangles will have a large converging normal direction, and the shared edges of the two triangles will start to fight for the right to render this edge, because they appear to be one edge, but they are actually composed of different but overlapped vertices, see Figure 45.


#figure(
  image("figures/fightnorm.svg", width: 90%),
  caption: [
    Fighting normal
  ],
)

//![fighting normal]

// 但是造成这样的视觉flaw并不是最坏的结果，因生成多余顶点而消耗掉的gpu内存才是我们更要优化的地方。为了减少细分时所长生的冗余的顶点，现在的学术界并没有一个非常generic的解法，并且由于deduplication其实has a highly sequential nature，它其实更适合在cpu下执行，要在compute shader中并行的去除多余顶点是一件相对困难的事情. []提出了一个使用cuda的高并行的remove duplicate vertices的算法，但是毕竟cuda是另外一门语言，强行使其操作compute shader生成的数据需要引入许多额外的操作例如内存映射. 并且能直接生成compressed的数据，i.e.没有重复顶点的数据, 是最好的，for example，在一帧中的某个地方生成了500mb的数据，然后在这一帧中之后的某个地方将其压缩到200mb，尽管减少了内存使用，但是这样的行为有可能导致undefined behavior
//
// 根据不同的细分策略，实际上使用的duplicate vertices removal的策略也会不同，比如如果是wild range tessellation的话，比如说以整个cluster为基础，做tessellation，那么要去除的重复顶点只会存在于cluster的边缘，所以很难去提供一个generatic的方法

But causing such a visual flaw is not the worst result, the gpu memory consumed by generating redundant vertices is what we need to optimize more. In order to minimize the redundant vertices generated during tessellation, there is no very generic solution in the academic world so far, and since deduplication has a highly sequential nature, it is actually more suitable for CPU execution, and removing the redundant vertices in parallel in a compute shader is a relatively difficult task. 

[], A highly parallelized vertices removal algorithm using cuda was proposed, but cuda is a different language, and forcing it to manipulate the data generated by the compute shader would introduce many additional operations such as memory mapping. 

// For example, generating 500mb of data somewhere in a frame and then compressing it to 200mb somewhere after that frame may reduce memory usage, but such behavior may result in undefined behavior
Ideally, it is best to generate compressed data directly—i.e., data without duplicated vertices. For example, if 500 MB of data is generated at one stage of a frame and then compressed to 200 MB later in the same frame, this may reduce memory usage, but such behavior can potentially lead to undefined behavior.

The duplicate vertices removal strategy will be differ from different tessellation strategy. For example, if the tessellation is a wild range tessellation, say based on the whole cluster, the duplicate vertices to be removed will only exist at the edges of the cluster. As a result, providing a universal solution for duplicate vertex removal remains difficult.

//so it is hard to provide a generatic method to remove duplicate vertices.

#figure(
  image("figures/my.png", width: 30%),
  caption: [
    Missing
  ],
)

//![duplicate vertex的占比问题]

// 注意：以下是这是如果完成了deduplication才用得上的内容


== Next-Gen Geometry Pipeline

// 既然compute shader与传统渲染管线的通信代价如此之大，比如说要将生成的数据写回gpu的内存，增加内存开销的同时，还增加了shader的io操作，而hardware tessellation会将生成的顶点数据直接分批传入gpu的cache，直接参与到后续的渲染工作而不需要写会gpu内存。
//
// 那有没有什么办法是可以即有compute shader tessellation的灵活性，又可以避免浪费计算和内存资源呢。介绍一下mesh shader这里，比如说介绍的时间，想要解决的问题等等
//
// ![mesh shader pipeline]
//
// 并且使用mesh shader pipeline还可以避免传统渲染管线带来的诸多问题：
//
// 传统管线的一些坏处：冗余的vertex shader invocation，不能高并发利用gpu的计算资源
//
// ![vertex shader from amd post]
//
// mesh shader直接进入gpu caceh
//
// 但是限制了max pattern的, 但可以split
//
// 很多hardware暂时还不支持mesh shader， 对于需要提供跨平台支持的引擎，比如frostbite，mesh shader可以做成可选的

//------

// 尽管基于 Compute Shader 的tessellation方案在灵活性上相比传统硬件管线有显著优势，但它也带来了不可忽视的开销问题。由于 Compute Shader 无法直接将生成的顶点数据传入后续图形流水线，其输出必须写回 GPU 的内存，这不仅带来了额外的 IO 操作，还显著增加了内存带宽的压力，影响了整体渲染性能。而在Hardware Tessellation中，生成的顶点数据通常可直接写入 GPU cache 并参与后续的图形渲染流程，无需经由显存回写的中间步骤，极大地减少了资源浪费。
//
// 为此，我们希望寻求一种方法，能够在保有 Compute Shader 所带来的灵活性与可编程性的同时，也能规避不必要的内存开销与计算浪费。这正是 Mesh Shader 被提出的初衷。Mesh Shader 最早由 NVIDIA 于 Turing 架构[]中引入，并在随后被 Microsoft DirectX 12 和 Vulkan API 正式支持, see Figure X.

Although the Compute Shader-based tessellation scheme has a significant advantage over the traditional hardware pipeline in terms of flexibility, it also brings a non-negligible overhead problem. 

Since the Compute Shader cannot directly pass the generated vertex data into the subsequent graphics pipeline, its output must be written back to the GPU's memory, which not only brings additional IO operations, but also increases the pressure on the memory bandwidth, affecting the overall rendering performance. In contrast, vertex data generate by the hardware tessellation usually is directly written to the GPU cache and participate in the subsequent graphics rendering process without the intermediate step of writing back to the memory, which greatly reduces the waste of resources.

// Therefore, we need a way to avoid unnecessary memory overhead and computational waste while maintaining the flexibility and programmability of a Compute Shader. This is why Mesh Shaders were first introduced by NVIDIA in the Turing architecture [] and have since been officially supported by Microsoft DirectX 12 and the Vulkan API, see Figure X.

// Therefore, Mesh Shader introduced by Nvidia[] allow us to avoid unnecessary overhead while maintaining the flexibility and high parallel computational capability. As shown in the Figure X, mesh shader和hardware tessellation一样，可以直接将输出的数据可以直接参与后续的渲染工作，并且由于task shader的存在，可以动态的dispatch mesh shader的数量，从而充分利用gpu高并行计算的能力

Therefore, Mesh Shader introduced by Nvidia[] allow us to avoid unnecessary overhead while maintaining the flexibility and high parallel computational capability. As shown in the Figure 47, mesh shader, similar to hardware tessellation, can directly pass the output data to the subsequent rendering work, and due to the existence of task shader, it can dynamically dispatch the number of mesh shaders, thus fully utilizing the gpu's highly parallel computing capability. dispatch the number of mesh shaders, thus fully utilizing the gpu's highly parallel computing capability.

#figure(
  image("figures/meshpipe.jpg", width: 100%),
  caption: [
    Traditional graphics pipeline vs. Mesh shader pipeline
  ],
)
//![mesh shader pipeline]

// 此外，Mesh Shader Pipeline 还能有效解决传统渲染管线中存在的一些性能瓶颈。例如，在传统管线中，同一个vertex有可能被多个vertex shader执行，导致完全没必要的计算浪费,see Figure X。同时，由于图形流水线各阶段固定，缺乏足够的灵活性，也难以充分发挥现代 GPU 在大规模并行计算方面的优势。相比之下，Mesh Shader 允许以工作组（Workgroup）为单位，自主生成整个图元结构，并将结果直接写入 GPU 的本地 Cache，从而省去了中间回写显存的开销。

In addition, the Mesh Shader Pipeline can effectively solve some of the performance bottlenecks that exist in traditional rendering pipelines. For example, in a traditional pipeline, the same vertex may be executed by multiple vertex shaders, resulting in completely unnecessary wasted computation. At the same time, the fixed phases of the graphics pipeline lack sufficient flexibility and make it difficult to fully utilize the advantages of modern GPUs in massively parallel computation.  

// In contrast, the Mesh Shader allows the generation of entire primitive structures at the workgroup level. and the results written directly to the GPU's local Cache, eliminating the overhead of writing back to the graphics memory.

// 当然，Mesh Shader 也并非没有局限。目前为止，大多数消费级 GPU（如 NVIDIA Turing 及之后架构、AMD RDNA2 以上）才开始逐步支持该功能，尚未形成完整的硬件普及。对于需要跨平台支持的游戏引擎（例如 EA 的 Frostbite），Mesh Shader 更适合作为可选增强选项，以在高端平台上获得更高性能和更好效果，
//
// 同时，由于一个 Mesh Shader 的执行范围受到单个 workgroup 的限制，其最大可生成的顶点数与三角形数量也有一定上限（如 128 组 Primitive，256 个顶点）。因此max pattern也会收此影响，但是我们可以通过对原始网格进行拆封从而避免单个triangle的tessellation太大而没有pattern可以满足的问题[mega geometry]。

// However, most consumer GPUs so far, for example NVIDIA Turing and later architectures, AMD RDNA2 and above, have only begun to gradually support this feature, and it has not yet become a complete hardware popularization. For game engines that require cross-platform support, e.g. EA's Frostbite, Mesh Shaders are better suited as an optional enhancement to achieve higher performance and better results on high-end platforms.
//
// At the same time, since the execution range of a Mesh Shader is limited by a single workgroup, the maximum number of vertices and triangles that can be generated by a Mesh Shader has an upper limit, 128 Primitive groups, 256 vertices depending on different hardware and GPU vendor. Therefore, the maximum size of a pattern is limited by this constraint, we can avoid this problem by keeping split the triangle whose tessellation level is too large to match any existing pattern until it satisfies to the pattern we have[mega].

However, the output of mesh shaders are limited by hardware constraints—typically up to 256 vertices and 128 primitives per workgroup. As a result, the size of reusable patterns is also constrained. To handle cases where a triangle’s tessellation level exceeds available patterns, we can iteratively split it until it fits within a supported pattern [Mega Geometry].

== Visual effect

// 还有提一下即便使用了4k的displacement texture，在Tessellation rate非常高的时候同样会出现由于精度不足出现的artifacts，see Figure 48
Even when using a 4K displacement texture, at very high tessellation rates each triangle can become smaller than a single pixel. In such cases, the limited bit depth used to store scalar values may not provide enough precision, leading to artifacts as shown in Figure 48.

#figure(
  image("figures/dmartifacts.png", width: 60%),
  caption: [
    Displacement artifacts when tessellation is too high
  ],
)
//![displacement artifacts]

// 由之前的结果可以看出, 由于我们只是增加了三角形的密度，并没有做像subdivision surface那样的平滑处理，所以从视觉效果上看，即使通过rasterizer为三角形内部的顶点信息做了插值平滑处理，但是模型的外轮廓还是显得很棱角分明的, see figure X

As you can see from the previous results, since we only increased the density of the triangles and did not do any smoothing like the subdivision surface, visually, even though we interpolated and smoothed the vertex normal inside the triangles with the rasterizer, the silhouette of the model still looks sharp and angular, see Figure 49.

#figure(
  kind:image,
  caption: [Side view from the same model of tessellation(left) and subdivision(right)],
  table(
    columns: 2,
    stroke:none,
    image("figures/tessside.png"),
    image("figures/subdside.png", height: 27%),
  )
)

//![subdivision vs tessellation in blender]

// 常见的提升手段大概分为两种，一种是直接渲染subdivision surface，一种是在flat triangle的基础上构建高阶平滑曲面。
Common approaches to improve this are generally divided into two categories: one is directly rendering subdivision surfaces, and the other is constructing higher-order smooth surfaces based on flat triangles.

// Subdivision Surface实际上是在粗糙网格基础上，反复应用Subdivision Schemes[]，通过不断生成并加权调整顶点位置来实现表面平滑。这就导致到adaptive的subdivision计算量会非常大，特别是对于animated mesh，因为运动的网格有可能随时会改变该区域的geometric complexity从而引发每帧的subdivision level都不一样，而这不仅仅要生成顶点，还需要根据加权算法，offset每个已经生成的点到对应为以获得光滑的表面。但是 [efficient quad tree]介绍了利用quad tree提前生成subdivision plan从而在gpu中快速并高效的渲染subdivision surface
//
// 而pn triangle则是另一种做法当中的代表，通过在flat triangle上构造高阶平滑曲面

// Subdivision Surface实际上是在粗糙网格基础上，反复应用Subdivision Schemes[]，通过不断生成并加权调整顶点位置来实现表面平滑。这种方法在适应性Subdivision（adaptive subdivision）时，计算量尤其庞大。尤其对于动态网格（animated mesh），由于几何复杂度随时间变化，每一帧的Subdivision Level可能都不同，这不仅要求动态生成大量顶点，还需根据加权规则对已有顶点位置进行偏移，以保证曲面光滑。对此，已有研究如[Efficient Quad Tree]提出利用四叉树结构预先生成Subdivision计划，从而实现Subdivision Surface的高效GPU渲染，大幅提升性能。
//
// 另一种代表方法是PN Triangle，通过在平面三角形基础上构造高阶曲面，用较少的计算代价获得较为平滑的视觉效果。PN Triangle通过插值顶点位置和法线，构建二次Bezier曲面，从而显著改善平面三角形带来的棱角感，且相比完整Subdivision，计算更为轻量，适合实时渲染。除了PN Triangle，近年来基于着色器的曲面细分与拟合技术也逐渐兴起，比如利用Bezier Patch、Gregory Patch等高阶曲面模型

Subdivision Surface is actually the iterative application of Subdivision Schemes [] on top of a coarse mesh to achieve surface smoothing by continuously generating and weighting vertex positions. This approach is particularly computationally intensive in the case of adaptive subdivision. Especially for animated mesh, the Subdivision Level of each frame may be different due to the change of geometric complexity over time, which not only requires the dynamic generation of a large number of vertices, but also needs to offset the positions of existing vertices according to the weighting rule to ensure the surface smoothness. In this regard, studies such as [Efficient Quad Tree] have proposed to pre-generate the Subdivision plan by using the adaptive quad tree structure, thus realizing efficient GPU rendering of Subdivision Surface in the GPU.

Another representative method is PN Triangle, which constructs higher-order surfaces based on planar triangles to achieve smoother visual effects with less computational cost. PN Triangle interpolates vertex positions and normals to construct quadratic Bezier surfaces, which significantly improves the angularity of planar triangles and is lighter in computation compared to the full Subdivision. 

It is also lighter than a full Subdivision, making it suitable for real-time rendering. In addition to PN Triangle, recent years have seen a rise in shader-based surface subdivision and fitting techniques, such as the use of Bezier Patch, Gregory Patch, and other higher-order surface models.

//2. Virtualize geometry + cluster based tessellation [unreal engine 5.5 doc]
// --- Subdivision surface approximation
//
// cons of directly rendering subd surfaces
//
// - not efficient in gpu implementation
// - change the topology every frame
// ( what's topology actually means? ) 
//
// --- Direct Subdivision Surface Rendering
//
// to be able to get a more smooth visual
//
// better visual details and more accurate re-calculate normals
//
// we can use stam algo to direct evalue the limit surface of the subd surface
//
// this method will be able to generated enough vertices for subdivision surfaces
//
// fast rendering of subdivision surfaces( a paper )
