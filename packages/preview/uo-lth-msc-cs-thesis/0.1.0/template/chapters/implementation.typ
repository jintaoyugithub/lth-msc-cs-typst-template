#import "@preview/algorithmic:1.0.0"
#import algorithmic: algorithm

= Implementation

_In this chapter we present the implementation details of the compute shader based tessellation prototype_
#v(15pt)

== Pipeline Overview

Building upon the insight from the previous studies, we provide a compute shader based pipeline to demonstrate how we can leverage the GPU's massive parallelism to reconstruct high-fidelity geometry in real time. To better illustrate the structure and functionality of our system, we present detailed explanations of several crucial stages in our pipeline in the following sections.

//the two main pipeline stages: the offline phase and the runtime phase, as shown in Figure X and Figure X.

=== Resources Overview

This section summarizes the GPU resources used throughout the pipeline. Each resource plays a specific role in different stages of the rendering process, ranging from visibility determination to normal recalculation. Table 1 provides a detailed breakdown of these resources, including their types, usage stages, and descriptions.

// #let a = table.cell(
//   fill.gray.lighten(60%),
// )[Name]

#let a = table.cell(
  fill: gray.lighten(20%),
)[Name]

#let b = table.cell(
  fill: gray.lighten(20%),
)[Type]

#let c = table.cell(
  fill: gray.lighten(20%),
)[Stages]

#let d = table.cell(
  fill: gray.lighten(20%),
)[Description]

#show table.cell.where(y: 0): strong

#figure(
  table(
    columns: 4,
    align: left,
    rows: 1cm,
    a, b, c, d,
    [Input Mesh data], [SSBO], [All Compute Stages], [Mesh data of the coarse mesh],
    [Pattern Table], [SSBO], [All Compute Stages], [Different levels of refine pattern],
    [LookUp Table], [SSBO], [All Compute Stages], [Entry point to Pattern Table],
    [Triangle Visibility], [SSBO], [All Compute Stages], [ID of the visible triangles],
    [Data Counters], [UBO], [All Compute Stages], [All atomic counters],
    [Vertex Tessellation Rate], [SSBO], [All Compute Stages], [Tess factor of each vertex],
    [Indirect Commands], [SSBO], [Indirect Setup], [Setup indirect commands],
    [Scene Information], [SSBO], [All Compute Stages], [Scene Configuration],
    [Frame Constants], [UBO], [Vertex Shader\ Fragment Shader], [Constants for each frame],
    [Refined Vertices], [SSBO\ Vertex Buffer], [Tessellation Stage\ Vertex Shader], [Generated vertices],
    [Refined Indices], [SSBO\ Index Buffer], [Vertex Shader], [Generated triangles],
    [Normal], [SSBO], [Fragment Shader], [Normal of deformed mesh],
  ),
  caption: [Resources Reivew],
)

In Table 2, we present the mesh data we used in this project.

#let e = table.cell(
  fill: gray.lighten(20%),
)[Triangle Counts]

#let f = table.cell(
  fill: gray.lighten(20%),
)[Vertices Counts]

#let g = table.cell(
  fill: gray.lighten(20%),
)[Edges Counts]

#let h = table.cell(
  fill: gray.lighten(20%),
)[Disk Size]

#let i = table.cell(
  fill: gray.lighten(20%),
)[Memory Size]

#figure(
  table(
    columns: (5cm, 2cm, 2cm, 2cm, 2cm, 2cm),
    align: left,
    rows: 1.0cm,
    a, e, f, g, h, i,
    [Big guy coarse mesh], [2900], [1452], [2900], [145 KB], [292 KB],
    [Big guy detail mesh], [2,969,600], [1,484,802], [2,969,600], [241 MB], [363.7 MB],
    [Big guy displacement texture], table.cell(colspan: 3, align: center)[N/A], [1.2 MB],[13.2 MB]
  ),
  caption: [Input Mesh Data Reivew],
)


=== Data-preprossing

In the offline phase, two key components are generated: the tessellation patterns set and a lookup table that indexes them in the GPU memory. Each pattern consists of a set of vertices and triangle indices, which are stored in two large, contiguous memory blocks. The size of each block is determined by the total number of vertices and indices across all supported tessellation levels (from level 0 to the maximum), as shown in left side of Figure 17. For example, the first three vertices in the memory block belong to the first pattern, the next six to the second pattern, and so on. The same layout applies to the index buffer.


#figure(
  image("figures/offline.png", width: 100%),
  caption: [
    Offline processes
  ],
)

The lookup table stores the entry points for each pattern, making it efficient to access the appropriate pattern directly in GPU memory during execution. Additional information such as the indices of edge vertices on the coarse triangle is also stored to facilitate vertex reuse when applying patterns.

=== Real time framework

During the runtime phase, the system runs a sequence of compute-shader-based stages: resource cleanup, triangle visibility determination, tessellation level computation, pattern-based tessellation, and normal recalculation, see Figure 18. Since compute shaders operate within an isolated pipeline and cannot directly render to the screen, we must transfer the generated vertex and index data to the traditional rendering pipeline using SSBO, which are then bound to the vertex and fragment shaders.

#figure(
  image("figures/realtimefw.png", width: 100%),
  caption: [
    Realtime compute shader based framework
  ],
)

At the very beginning of the pipeline, several resources must be reset, because they varied every frame, such as buffer store the triangles that are visible, atomic counter that track generated vertices and triangles, see Table 1. Once the resources are properly reset, the system proceeds to determine which triangles in the input mesh are visible to the current camera, then we compute the tessellation level for each vertices from the visible triangles, based on that, the tessellation compute shader will fetch the corresponding pattern from the tessellation patterns set with the look up index, generated vertices and indices data are then written to two final buffer and subsequently bond to vertex shader to finalize the rendering.

If there are displacement textures available, vertex positions are adjusted during the tessellation stage and one additional compute pass is needed to re-calculate the normals from the the displaced vertices.

// In the runtime phase, the system executes a sequence of compute-shader-based stages including resource cleanup, triangle visibility determination, tessellation level computation, pattern-based tessellation and normal recalculation (see Figure X). Since compute shader是一个相对独立的计算管线，它并没有渲染的能力，所以要将compute shader生成的三角形渲染到屏幕上，我们还必须通过ssbo来与vertex shader和fragment shader传输数据.

// To better illustrate the workflow of our system, we provide a further detailed overview of the two full processing pipeline stages: offline and run time are shown in the Figure X and Figure X.
//
// In the offline process, there are two main phases patterns generation and look up table generation. First we store the vertices and indices data of each pattern into two separate big and continuous memory block whose size is depending on the sum from pattern with 0 tessellation level to maximum tessellation level, demonstrate in Figure X (a). In vertices memory block, for example, the first three store the vertices of the first pattern, the following six store the vertices of the second pattern and etc., same for the data in indices memory block.
//
// The look up table stores the entry points to the vertices and indices data of the corresponding patterns we store previously, making it easier to search where the desired pattern is located in the GPU memory.
//
// During the run time, there are five main stages, including resources clean up, triangles visibility determination, tessellation rate computation, xxx, normal recalculation, see Figure X. Each stage is construct by a compute shader

// ![Pipeline Overview]
// ![pattern generation memory view]
// ![look up table memory view]

== Patterns Generation

// To enable flexible and effcient GPU-based tessellation, this section describe the algo shown in Code X, we use to generate可复用的uniform patterns, with these patterns, samller triangles can be simply generated with 简单而高效barycentric interpolation计算in the gpu
//
// the order of the vertices and triangles are essential因为这会影响到之后vertices reuse的算法, 所以每一个pattern的vertices和triangles顺序都将遵循从左网友，从下至上逐渐变大, see figure x.
//
// 对于每个顶点我们存储其对应的barycentric坐标, see figure X(b), 我们可以将figure X(c)中的pattern分为x个level，而每一层我们都可以看成是对u线性插值with v increased by 1/depth every loop, see Figure X, 由于barycentric坐标的特性并且出于减少table对内存的使用的目的，每个顶点我们只存储其barycentric坐标中的uv，因为w可以通过一下公式算出：

In order to achieve flexible and efficient GPU-based tessellation, this section presents algorithms for generating reusable uniform triangle patterns. With the help of these patterns, smaller, finer triangles can be quickly generated on the GPU side by simple and efficient interpolation of the barycentric coordinates.

It's crucial to note that the ordering of the vertices and triangles matters as it affects the efficiency of the subsequent vertex reuse algorithms. Therefore, the vertices and triangles in each mode are arranged in left-to-right and bottom-to-top order, as detailed in Figure 19.

#figure(
  image("figures/triangle.svg", width: 70%),
  caption: [
    Vertices order(left), Triangle order(right)
  ],
)

//![vertices and triangle order]

For each vertex, we store its corresponding barycentric coordinates. We can divide the example pattern show in the Figure 20 into tessellation levels which 3 in the example, and each level can be regarded as a linear interpolation along u, with v increasing by 1 divied by depth, i.e. tessellation rate in each iteration. Due to the properties of barycentric coordinates and to reduce memory usage, we only store the u and v components of the barycentric coordinates for each vertex, since w can be calculated with $w = 1.0 - u - v$.

//![inter level 1; inter level 2, transparent]

#figure(
  image("figures/triangledepth.svg", width: 100%),
  caption: [
    Vertices interpolation with gradually increase depth value
  ],
)

#v(10pt)
#line(length: 100%)
#v(-1pt)
#text(size: 12pt, weight: 700)[Algorithm 1]  #text(size: 12pt, weight: 600)[Pattern Vertices Generation]
#v(-1pt)
#line(length: 100%)
#v(-5pt)
#algorithm({
  import algorithmic: *
  Function(
    "PatternVertices",
    ("max_tess_rate", "pattern_vertices"),
    {
      Assign[idx][0]
      Assign[cur_tess_rate][$1$]
      For($"cur_tess_rate" <= "max_tess_rate"$, {
        Assign[$i$][$0$]
        Assign[$j$][cur_tess_rate]
        For($i <= "cur_tess_rate"$, {
          For($j >= "cur_tess_rate"-i$, {
            Assign[fracs][$i/"cur_tess_rate", j/"cur_tess_rate"$]
            let Lerp = Fn.with("Lerp")
            Assign[bary_coord][Lerp[fracs]]
            Assign[pattern_vertices[idx]][bary_coord]
            Assign[idx][idx+1]
            Assign[j][j-1]
          })
          Assign[i][i+1]
        })
        Assign[cur_tess_rate][cur_tess_rate + 1]
      })
    },
  )
})


// 每个pattern的深度值可以通过tess rate - 1轻松算出. 为了高效地构建可重用的 Uniform Pattern，我们在 CPU 端预计算每个 pattern 中的三角形拓扑关系（即索引顺序). 我们将当前的三角形沿着它的右边补充一个三角形，让其成为一个四边形，这是为了让两个简单循环就可以算出我们所要的order, see figure X. 
//
// 我们以 pattern 的深度为循环变量，从最底层开始，依次利用当前层以及下一层的顶点信息构造在其之间的三角形。为了避免对于的内存遍历和索引越界，我们并不需要多出来的在虚拟三角形上的顶点信息，所以我们可以通过等差数列前项和以及depth来计算出针对每一层的最大索引值，当有顶点超过对应层数的最大索引值时候，则放弃生成当前三角形的index，see figure x and equation 等差数列前祥和.

To efficiently build reusable Uniform Patterns, we precompute the triangle topology, i.e. index order of each pattern. We make the current triangle a quadrilateral by adding a virtual triangle along its right side, so that two simple loops can compute the order we want, see Figure 21. We use the depth of the pattern as the loop variable. 

//![triangle order, separate the inner triangles like /\\/] 

#figure(
  image("figures/2triangle.svg", width: 50%),
  caption: [
    A example pattern for computing triangle indices
  ],
)

We use the depth of the pattern as the basic for the loop, starting at the bottom, and constructing the triangles in between, using ID information about the vertices of the current layer and the next layer in turn. To avoid unnecessary memory traversal and index out of bounds, we don't need the extra vertex information on the virtual triangles, so we need to calculate the maximum index value for each layer by using the partial sum of an arithmetic sequence and the depth value, and give up on generating the index of the current triangle when there are vertices exceeding the maximum index value computed by formula (2) for the corresponding layer.

$ S_n = (n * (a_n - a_1)) / 2 $

#v(10pt)
#line(length: 100%)
#v(-1pt)
#text(size: 12pt, weight: 700)[Algorithm 1]  #text(size: 12pt, weight: 600)[Pattern Indices Generation]
#v(-1pt)
#line(length: 100%)
#v(-5pt)
#algorithm({
  import algorithmic: *
  Function(
    "PatternVertices",
    ("max_tess_rate", "pattern_indices"),
    {
      Assign[idx][0]
      Assign[prev_row_len][0]
      Assign[cur_tess_rate][1]
      For($"cur_tess_rate" <= "max_tess_rate"$, {
        Assign[depth][cur_tess_rate]
        Assign[$j$][0]
        For($j <= "depth"$, {
          Assign[max_idx][$((j+2) * (("cur_tess_rate" + 1) * ("cur_tess_rate" - j))) / 2 - 1$]
          Assign[num_row_quad][cur_tess_rate - j]
          Assign[cur_row_len][cur_tess_rate + 1 - j]

          Assign[i][0]
          For($i < "num_row_quad"$, {
            Assign[start_point][$i + (j * ("cur_tess_rate" + 1) + ("cur_tess_rate" - j )) / 2$]
            Assign[fir_point][start_point]
            Assign[sed_point][start_point + 1]
            Assign[thi_point][start_point + cur_row_len]

            Assign[pattern_indices[idx]][vec3(fir_point, sed_point, thi_point)]
            Assign[idx][idx+ 1]

            Assign[fir_point][start_point + 1]
            If($"fir_point" + "cur_row_len" > "max_idx"$, {
              Assign[sed_point][0]
              Else({
                Assign[sed_point][fir_point + cur_row_len]
              })
            })
            If($"sed_point" == 0$, {
              [continue]
            })
            Assign[thi_point][start_point + cur_row_len]
            Assign[pattern_indices[idx]][vec3(fir_point, sed_point, thi_point)]

            Assign[idx][idx+ 1]
            Assign[i][i+ 1]
          })

          Assign[j][j + 1]
        })
        Assign[cur_tess_rate][cur_tess_rate + 1]
      })
    },
  )
})


Using the above method, we can efficiently pre-generate triangle uniform patterns at arbitrary resolutions on the CPU side to support high-concurrency tessellation on the GPU. For detailed pseudocode, please refer to Algorithm 1 and Algorithm 2.

// 通过以上的方法，我们可以高效的在cpu端预先生成任意分辨率下的三角形uniform pattern, 以支持在在gpu上的高并发细分。详细的伪代码请看algo 1 and algo 2


//== table construction

== Visibility and tess rate determination

// 除了资源的重置，这两个可以算是real time pipeline的正式开端。我们必须在管线的开始就去除掉看不见的三角形是因为很明显这些三角形参加后续的计算是没有意义的，我们并不想把宝贵的计算和内存资源浪费在根本看不见的三角形上面
//
// 而我们决定三角形的visibility的方法相对简单，类似于传统渲染管线中back face culling,
// 我们为每个三角形构造face normal，然后根据camera的view dir和其face normal的dot product来决定可见度，》0可见，《=0则不可见
//
// ![back face culling]
//
// 通过计算每个点与camera的距离，我们通过不同的阈值来决定什么距离段的顶点应该赋予什么样的曲面细分等级。
//
// ![vertex tess rate determination with camera]
//
// 因为本文更加注重整个compute shader based的渲染管线的框架，所以在tess rate的赋值上为了避免后续由于相邻三角形引起的不同的tess rate而引起的T-junction[]问题，后续我们一律给每个vertice赋值同样的tess rate。

// 除了资源的初始化，实时渲染管线的正式执行可以看作从两个关键步骤开始：三角形可见性剔除和曲面细分等级（Tessellation Rate）的分配。在管线的初始阶段就剔除不可见的三角形是非常有必要的，因为这些三角形在后续计算中不会对最终结果产生任何贡献，却会消耗宝贵的计算和内存资源，造成性能浪费。
//
// 我们采用了一种类似于传统渲染管线中背面剔除（Back-face Culling）的方法来判断三角形的可见性。具体做法是：首先为每个三角形构造一个面法线（Face Normal），然后计算其与摄像机视线方向（View Direction）之间的点积（Dot Product）。当点积大于 0 时，三角形朝向摄像机，被认为是可见的；当点积小于等于 0 时，说明该三角形背向摄像机，将被剔除。该方法简单高效，适用于并行处理。

In addition to resource initialization, the formal execution of a real-time rendering pipeline begins with two key steps: rejection of non-visible triangles and surface tessellation rate assignment. Discarding invisible triangles at the initial stage of the pipeline is essential because these triangles do not contribute to the final result in subsequent computations, but consume valuable computational and memory resources, resulting in wasted performance.

To this end, we employ a strategy similar to fixed function culling in the graphics hardware, i.e. back culling to determine the visibility of triangles. Specifically, we first construct a face normal for each triangle and compute the dot product between it and the camera view direction. If the dot product is greater than zero, the triangle is facing the camera and is visible; conversely, if the dot product is less than or equal to zero, the triangle has its back to the camera and should be culled. This approach is both simple and efficient, and is especially suitable for parallel computing environments.

//![背面剔除示意图]

#figure(
  image("figures/culling.svg", width: 80%),
  caption: [
    Culling
  ],
)

//![模型culling vs. witou culling]

// 完成可见性筛选后，我们为剩余的顶点分配曲面细分等级。该等级由顶点到摄像机的距离决定，距离越近的顶点会被赋予更高的细分等级，从而在视觉上获得更丰富的几何细节。下图展示了细分等级随距离变化的策略：

// After completing the visibility filter, we assign a surface subdivision level to the remaining vertices. The level depends on the distance from the vertex to the camera - vertices that are closer will be assigned a higher subdivision level, resulting in visually richer geometric details. The Figure 23 illustrates the strategy of varying the tessellation level with distance to the camera.
//
// //![基于摄像机距离分配细分等级示意图]
//
// #figure(
//   image("figures/my.png", width: 40%),
//   caption: [
//     Missing
//   ],
// )

However, the focus of this paper is on the design of the rendering pipeline framework based on the Compute Shader. In order to simplify the implementation and avoid the T-Junction problem caused by the inconsistency of the tessellation levels of neighboring triangles, we choose to uniformly assign the same level to all vertices. The possible impact of this strategy and how we further deal with the T-Junction problem will be discussed in detail in the following sections.

// 然而，本文主要关注基于 Compute Shader 的渲染管线框架设计，因此在实际实现中，为了避免由相邻三角形存在不同细分等级所引发的T-Junction 问题，我们选择为所有顶点统一赋予相同的细分等级。我们会在后续的章节中讨论如何解决这个问题

== Tessellation and Displacement

// 有了前面的准备工作，真正执行tessellation的时候并不涉及什么复杂的算，只要根据取到的pattern上面的bary coord以及真实的顶点数据from corase triangle，通过简单的插值公式，see equation 1, 来获得真正的顶点位置数据。不仅仅是顶点位置数据，许多其他attributes同样也可以通过这个方式获得，比如法线，纹理坐标等等, see Figure X.

After the preparatory work, the actual execution of Tessellation itself is not complicated. The core of Tessellation is to use the barycentric coordinates of the pre-generated pattern and the vertex data of the original coarse triangle to calculate the real vertex positions after refinement by the interpolation formula (1).

// This interpolation method is not only suitable for vertex position calculation, but also for obtaining other attributes, such as normals, texture coordinates, etc. See Figure X.

#figure(
  image("figures/tessellation.svg", width: 100%),
  caption: [
    Tessellation process
  ],
)

// ![barycentric coord in triangle + actual coarse position = actual position in triangle]

To further enhance geometric detail, displacement mapping can be applied on top of the interpolated surface. Once the base position is computed through barycentric interpolation, we offset it along the original surface normal using a displacement value sampled from a displacement texture. This value is typically fetched using the corresponding interpolated texture coordinates. 

#figure(
  kind:image,
  caption: [Displacement Mapping],
  table(
    columns: 2,
    stroke:none,
    image("figures/origin.png", height: 35%),
    image("figures/displaced.png", height: 35%),
  )
)


//![部分coarse mesh(with pattern) + displacement texture]

=== Vertices Deduplication

TODO

// 因为tessellation是针对每个coarse triangle的，并没有考略整体的拓扑信息，导致在细分的时候，triangles which share the same edges will 在相同的位置生成duplicate vertices, see figure X
//
// ![shared points view]
//
// ![flicking normal in side coarse triangle]

== Normal Re-Calculation

// 如果只是对terrain进行displacement mapping的话，即使我们不做过多的处理，也能通过quad垂直向上的法线得到还不错的光线效果，而对于dynamic water这种，通过数学函数来进行vertex postion offset的，也可以直接通过数学公式来获取displaced后的法线。但对于复杂的3D模型来说, 如果不像借助法线贴图，需要借助一些别的方法重新计算displaced之后的法线
//
// 如果要通过displacement mapping计算法线，首先算出来的法线是固定的如果我们用displacement texture中的一点以及临近点的值来算derivative，并且生成的法线是在tangent space，意味着需要存储额外的信息来构造tbn矩阵，才能获得正确的法线。而如果要计算每个点的particial derivatives， 都需要获得它相邻的点的信息，而对三角形这样的primitive来说并不是一个很容易的事情，而quad是很好做这件事情的，所以为什么mega geometry使用subdivision plan。
//
// ![想一下三角形找垂直方向的点]
//
// 如果我们只使用face normal的话，会导致每个三角形最后看起来很平，所以我们需要计算每个vertices normal, 这样rasterizer就会帮我们插值三角形内部的法线值, see figure x. 为了得到更加smooth的法线，本文使用了另外一种方法, 可以看出一个顶点可以被多个与之连接的顶点影响，针对每一个细分的三角形，我们构造其face normal，这个face normal会被作用在组成这个三角形的三个顶点上。所以，以figure x中的三角形拓扑举例子，点x被多少多少个三角形影响，那么针对每一个与之相连的三角形，构造face normal，叠加在构造该三角形的三个点上，可以看出，点x将会叠加x个三角形的face normals，因为我们是针对每一个三角形，由于compute shader高并发的特性，在该compute shader结束执行之前，我们都没办法得到一个最终的normals，所以我们在后续使用的时候将其进行normalize而得到正常范围内的normal

// In the case of dynamic water or procedural generated terrain, where the vertex positions are offset by mathematical functions or noise function e.g. perlin noise[], the normals can also be calculated directly from the corresponding mathematical expressions, 甚至对于terrain来说，本身垂直向上的法线，就算不做过多处理，能还能得到一个大致正确的光照结果
In the case of dynamic water or procedurally generated terrain, where vertex positions are offset by mathematical functions or noise functions such as Perlin noise @perlin1985image, normals can also be directly calculated from the corresponding mathematical expressions. Even for terrain, whose normals naturally point mostly upwards, reasonably accurate lighting results can still be achieved without extensive processing.

However, when dealing with complex 3D models, the situation is different. If we don't rely on a normal map, we need to recalculate the displaced normals in some other way. Computing derivatives from scalar displacement texture gives us the normal in tangent space, but it requires extra data to build a TBN matrix. Calculating partial derivatives per point also needs access to neighboring points, which is not straightforward for triangle primitives, see Figure 25.

//![想一下三角形找垂直方向的点]

#figure(
  image("figures/recalnormal.png", width: 100%),
  caption: [
    Quad has better topology to calculate derivatives than triangle
  ],
)

If only face normal is used, each triangle will appear distinctly flat and the overall effect will be stiff. Therefore, it is more desirable to compute normals for each vertex, so that during the rasterization phase, the GPU can interpolate the normals inside the triangles, resulting in a smoother surface effect. Specifically, for each tessellated triangle, we first construct its face normals and accumulate them to each of the three vertices constituting the triangle. Taking the topology in Figure 26 as an example, if a vertex X is connected to multiple triangles, then that vertex will receive the face normals from each neighboring triangle. In this way, the final normal of vertex X is jointly determined by the normals of all its neighboring triangles, providing better smoothing.

#figure(
  image("figures/accuproc.svg", width: 100%),
  caption: [
    todoclear
  ],
)

Since this process is executed in parallel in the Compute Shader, the final normals of all vertices are not immediately available until the end of the calculation. Therefore, these normals need to be normalized to ensure they are in the correct range before they are subsequently used.

// #figure(
//   image("figures/my.png", width: 30%),
//   caption: [
//     test
//   ],
// )
//
// ![flat normal and smooth normal]


//![点和triangles，影响, 比如第一个影响，然后第二个]

#figure(
  image("figures/accunormal.svg", width: 100%),
  caption: [
    accumulated normals(left) and normalized normal(right)
  ],
)

//![normal accumulation]

