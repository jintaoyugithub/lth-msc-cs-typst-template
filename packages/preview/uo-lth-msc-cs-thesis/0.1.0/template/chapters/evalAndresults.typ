= Evaluation and Results

// _In this section, we present a comprehensive evaluation of our pattern-based compute shader tessellation approach, we adopt a combination of quantitative and qualitative criteria, focusing on correctness, visual fidelity, performance. todo_

_In this chapter, we present a comprehensive evaluation of our pattern-based compute shader tessellation framework. We adopt a combination of quantitative and qualitative criteria, including most of the stages in the pipeline. In terms of performance evaluation, we compare our approach against existing methods including hardware tessellation, other GPU tessellation schemes and virtualize geometry system Nanite._
#v(20pt)

// visual effect
// ![same pattern with different model, arbitary topology]
// 以及
// ![不同attribute，like position, normal, uv]
//
// ![one camera view, one side view, tess with culling and without] 比如说你freeze the camera
//
// ![terrain displacement mapping]
// ![model displacement mapping]
//
// 然后指出lighting问题
//
// ![terrain normal recal vs. no normal recal]
// ![model normal recal vs. no normal recal]
// directly affect the lighting effect
// ![lighting with normal recal vs. no normal recal]

// performance
// ![不同lod下，比如20，40，60，max下的性能对比, 内存的占用，帧率]
//
// ![单独展示超大规模的tessellation, 同于与hw tess对比]
//
// ![对比直接渲染超大模型 vs 使用tessellation的性能对比]
//
// ![对比hardware tessellation vs 我们的compute shader tessellation]
//
// ![对比nanite vs 我们的compute shader tessellation]
//
// ![对比gpu quad tree tessellation]
//
// ![渲染复杂度*]

== Visual Quality Analysis

// Visual Quality的评估，主要从geometric fidelity，attribute coherence and shading and visual consisitency展开
The evaluation of visual quality mainly focuses on geometric fidelity, attribute coherence, shading, and visual consistency

=== Visibility and Tessellation

Here in Figure 28 and 29, we show how the same tessellation pattern with level 10 can be reused across models with completely different topologies. Despite variations in vertex connectivity and surface curvature, the pattern-based method maintains geometric correctness and visual consistency.

#figure(
  kind:image,
  caption: [Suzzane coarse mesh(left) and tessellated Suzzane mesh],
  table(
    columns: 2,
    stroke:none,
    image("figures/monkey_coarse.png", width: 90%),
    image("figures/monkey_tess.png", width: 91%),
  )
)

#figure(
  kind:image,
  caption: [Big guy coarse mesh(left) and tessellated Big guy mesh],
  table(
    columns: 2,
    stroke:none,
    image("figures/bigguy_coarse.png", width: 85%),
    image("figures/bigguy_tess.png", width: 85%),
  )
)

//![terrain, monkey, bigguy with same pattern]

However, it is possible to increase the tessellation level to 100, the following image demonstrate what is the model looks like with pattern 100 tessellation level.

#figure(
  image("figures/100tess.png", width: 100%),
  caption: [
    Big guy with 100 tessellation level
  ],
)

// Figure X compare culling impact of culling on visibility under a fixed camera view, 从第二张图片能看出，即使是简单的culling算法, 也能帮助我们剩下几乎百分之50的计算和内存开销。
Figure 31 compares the impact of culling operations on visibility at a fixed camera view. As can be seen in the second image, even a simple culling algorithm can help us save almost 50% of the computation and memory overhead.

#figure(
  kind:image,
  caption: [Side view of disable culling(left) and enable culling(right)],
  table(
    columns: 2,
    stroke:none,
    image("figures/sideviewnoclip.png"),
    image("figures/sideviewclip.png"),
  )
)

//![side camera view with culling, without culing]

=== Displacement Mapping

// Tessellation和Displacement mapping一直在程序化地形中扮演者重要的角色，而我们的方法同样也是可以引用在常见的地形生成上的, see Figure X.
Tessellation and displacement mapping have always played an important role in procedural terrain generation, and our method can also be applied to common terrain generation scenarios, see Figure 32.

#figure(
  kind:image,
  caption: [Terrain with 50 tessellation level(left) and with displacement mapping applied(right).],
  table(
    columns: 2,
    stroke:none,
    image("figures/quadtess.png"),
    image("figures/terraintess.png"),
  )
)

//![terrain tessellation view, terrain displacement mapping]

To evaluate the generality of our method, we further apply displacement to complex 3D models. Figure 33 shows that, even with arbitrary topology, our framework effectively refines the surface, extending beyond traditional terrain applications.

#figure(
  kind:image,
  caption: [Big guy with 10 tessellation level(left) and with displacement mapping applied(right).],
  table(
    columns: 2,
    stroke:none,
    image("figures/bigguytess.png", width: 90%),
    image("figures/bigguy_dm.png", width: 90%),
  )
)

//![model tessellation view, model displacement mapping]

=== Normal Recalculation

//In figure x, 我们可以看出，displacement过后的lighting计算并不是特别的准确
In Figure 34, we can see that the lighting calculation after displacement is not particularly accurate.

#figure(
  kind:image,
  caption: [Lighting results with original terrain normal(left) and model normal(right)],
  table(
    columns: 2,
    stroke:none,
    image("figures/terrain_norelnorm_light.png"),
    image("figures/model_norecalnorm_light.png", width: 80%),
  )
)

// 这是因为我们并没有对位移之后的顶点重新计算法线，一般来说deformed过后的mesh，由于表面的曲率发生变化，相应的对应的切线以及法线也会变化，see Figure X. 在terrain上可能不是很明显，Figure x中的结果说明在更复杂的3d模型上则更加容易看出
This is because we have not recalculated the normals of the displaced vertices. Generally speaking, when a mesh is deformed, the curvature of the surface changes, and so do the corresponding tangents and normals, see Figure 35. While this may not be obvious on a terrain, the results in Figure 36 show that it is easier to see on more complex 3D models. 

//![terrain normal recal vs. no normal recal]

#figure(
  kind:image,
  caption: [Terrain with input normal(left) and re-calculated normal(right) after displacement mapping],
  table(
    columns: 2,
    stroke:none,
    image("figures/terrain_norecalnorm.png"),
    image("figures/terrain_recalnorm.png"),
  )
)

//![model normal recal vs. no normal recal]

#figure(
  kind:image,
  caption: [Big guy with input normal(left) and re-calculated normal(right) after displacement mapping],
  table(
    columns: 2,
    stroke:none,
    image("figures/model_nocalnorm.png", width: 85%),
    image("figures/model_recalnorm.png", width: 85%),
  )
)

//Figure X中demonstrate 3d模型的lighting在不同法线下的影响
Figure 37 demonstrates the impact of different normals on the lighting of the 3D model.

#figure(
  kind:image,
  caption: [Lighting results with re-calculated normals],
  table(
    columns: 2,
    stroke:none,
    image("figures/terrain_recalnorm_light.png"),
    image("figures/model_recalnorm_light.png", width: 85%),
  )
)

//![lighting with normal recal vs. no normal recal]


== Performance Analysis

//texture, vertex data 用不同的颜色表示

// 我们在先前的chapter就有提到过，compute shader pipeline也会带来一些额外性能开销。下表详细描述了我们的framework中每个stage产生的开销，由于某些开销会根据模型不同而不同，所以这里统一采用bigguy作为input mesh data, 详细资料见table x， with fix tess pattern 70多, 因为这个pattern产生的三角形数量和hw最高tess level产生的差不多。

As we mentioned in the previous chapter, the compute shader pipeline also incurs some additional performance overheads. The following table and figure describes in detail the overhead incurred in our framework. 

// better to use table
// #figure(
//   image("figures/tessmem.png", width: 100%),
//   caption: [
//     Memory footprint of each buffer
//   ],
// )

#show table.cell.where(y: 0): strong
#set table(
  stroke: (x, y) => if y == 0 {
    (bottom: 0.7pt + black)
  },
  align: (left)
)

#let d = table.cell(
  fill: gray.lighten(20%),
)[Description]

#figure(
  table(
    columns: 2,
    rows: (0.8cm),
    align: (center),
    table.header(
      [Buffer Name],
      [Size in memory],
    ),
    [Triangles Visibility], [0.285 MB],
    [Refine Patterns], [5.47 MB],
    [Indirect Commands], [160 B],
    [Refined Vertices], [403 MB],
    [Refined Indices], [403 MB],
    [Scene Configuration], [64 B],
    [Re-calculated Normal], [403 MB],
    [Frame Constants], [176 B],
  ),
  caption: [Resources in GPU Memory],
)


It's worth noting that most of the memory here is pre-allocated in order to meet the needs of dynamically generated vertices, they might vary depending on the maximum number of triangles you ultimately wish to generate. In the following analysis, we focus solely on the actual memory used by the generated geometry, excluding the pre-allocated buffer space reserved for dynamic vertex generation.

Following figure show the GPU time of each stage in millisecond with the tessellation factor of 50, which will generate 7,250,000 triangles from the input coarse mesh with 2900 triangles.

#figure(
  image("figures/cs50.svg", width: 90%),
  caption: [
    GPU and CPU execution time of different stages
  ],
)

// Since some of the overheads will be different depending on the model, here we uniformly use Bigguy as input mesh data, see Table 2 for more details, with a fixed tessellation level of 78 out of 100 maximum, as this pattern produces about the same number of as that generated by the highest tessellation level of Hardware Tessellation.

// #show table.cell.where(y: 0): strong
// #set table(
//   stroke: (x, y) => if y == 0 {
//     (bottom: 0.7pt + black)
//   },
//   align: (left)
// )
//
// #figure(
//   table(
//     columns: 4,
//     rows: (1cm),
//     align: (center),
//     table.header(
//       [Stages],
//       [Memory Footprint],
//       [GPU Time (ms)],
//       [CPU Time (ms)],
//     ),
//     [Refine Patterns], [], [N/A], [N/A],
//     [Resources Clean Up], [N/A], [1.103], [0.074],
//     [Triangle Visibility], [285 KB], [0.010], [0.057],
//     [Indirect Command Setup], [ 0.16 KB ], [0.023], [0.060],
//     //[Tessellation level determination], [], [], [],
//     [Tessellation], [806 MB], [1.610], [0.030],
//     [Normal Re-calculation], [403 MB], [1.370], [0.018],
//     [Rendering], [N/A], [5.285], [0.118],
//   )
// )

// #align(center, block[
//   #move(dx: -34pt)[
//     #scale(80%)[
//       #table(
//         columns: (6cm,5cm,4cm,4cm),
//         rows: (1cm),
//         align: (left),
//         table.header(
//           [Stages],
//           [Memory Footprint],
//           [GPU Time (ms)],
//           [CPU Time (ms)],
//         ),
//         [Resources Clean Up], [N/A], [1.103], [0.074],
//         [Triangle Visibility], [285 KB], [0.010], [0.057],
//         [Indirect Command Setup], [ 0.16 KB ], [0.023], [0.060],
//         //[Tessellation level determination], [], [], [],
//         [Tessellation], [806 MB], [1.610], [0.030],
//         [Normal Re-calculation], [403 MB], [1.370], [0.018],
//         [Rendering], [N/A], [5.285], [0.118],
//       )
//     ]
//   ]
// ])

// The consumption, including rendering time and memory cost, share of each stage is shown in Figure 39 and Figure 40.
//
// #figure(
//   kind:image,
//   caption: [Lighting results with re-calculated normals],
//   table(
//     columns: 2,
//     stroke:none,
//     image("figures/terrain_recalnorm_light.png"),
//     image("figures/model_recalnorm_light.png", width: 85%),
//   )
// )

// 虽然记录自身框架的性能开销是必要的，但为了全面评估该方法的实用性，我们还必须将其与现有的几种主流方案进行对比。接下来，我们将依次展示与直接渲染高细节模型、硬件 Tessellation 以及 Nanite 等先进技术的性能对比结果。
While documenting the performance overhead of our own framework is necessary, in order to fully assess the utility of the approach, we must also compare it to several existing mainstream schemes. In the next section, we will show the performance results in turn against state-of-the-art techniques such as direct rendering of highly detailed models, Hardware Tessellation, and Nanite.


#v(15pt)
#block[
  #text(size: 15pt, weight: 700,)[Compare to original detailed mesh]
]
#v(15pt)

In Table 2, we present comprehensive information about the input detailed mesh data. This section we present the subsequent analysis focusing on model loading time, rendering time and memory consumption, see Figure 39. To get the same triangle amount, input coarse mesh will apply pattern with tessellation level 32 to generate $2900 * 32 * 32 = 2,969,600$ triangles.

// #figure(
//   table(
//     columns: 4,
//     rows: (1cm),
//     align: (center),
//     table.header(
//       [Approach],
//       [Asset Loading Time],
//       [Rendering Time],
//       [Memory Cost],
//     ),
//     [Original Model], [27820 ms], [], [],
//     [Coarse mesh with tessellation], [86.34 ms], [4.941], [],
//   )
// )


#figure(
  image("figures/tessvsori2.svg", width: 75%),
  caption: [
    Comparison between coarse mesh with compute shader tessellation and original detailed model
  ],
)

// 由于无法避免的必须将生成的顶点写会gpu内存，所以其实使用到的内存其实差不多，但是模型的加载时间从原来的27820ms减少到了86ms，渲染效率也相对提高了百分之37%，从7.3ms减少到了4.61ms

Since the generated vertices must inevitably be written back to GPU memory, the actual memory usage remains roughly the same — or even slightly higher due to the additional storage required for the displacement texture. However, the model loading time is significantly reduced from 27,820 ms to 88 ms, and the rendering performance also improves by approximately 45%, with the rendering time decreasing from 7.62 ms to 4.19 ms. Thanks to the early discard of invisible triangles, we actually render only about half the number of triangles compared to the original detailed mesh — while maintaining the same visual quality. Similarly, the memory consumption for the vertex and index buffers is also reduced by half, even taking displacement texture into account, the total memory usage amounts to only about 55% of the original model.

#v(15pt)
#block[
  #text(size: 15pt, weight: 700,)[Compare to Hardware Tessellation]
]
#v(15pt)

Since Hardware Tessellation directly stream generated primitive data to the GPU cache, although it is possible to estimate memory usage depending on the amount of generated vertices and triangles, we only consider the rendering consumption as hardware implementation detail such as data compression is unknown.

//下图对比了生成相同三角形的数量，两个approach的渲染表现
// The figure below compares the rendering performance of the two approaches with the same tessellation factors. As we can see, 在适中的tessellation factor时候，cs tessellation的process时间是稍微好一点，当tess factor太大或太小，都是hw tess的执行时间稍微短一些


#figure(
  image("figures/csvshwtess.svg", width: 85%),
  caption: [
    Comparison between compute shader tessellation with hardware tessellation in different tessellation factors
  ],
)

Figure 40 compares the rendering performance of the two approaches using the same tessellation factors. As we can see, rendering based on hardware tessellation is slightly more efficient than the compute-shader-based pipeline. However, since we did not recalculate the normals in the tessellation evaluation shader, if that process is omitted, the compute shader tessellation actually performs better overall.

//基于hardware tessellation的渲染其实要比compute shader based的渲染管线性能要好一些,但是由于我们并没有在tessellation evaluation shader中recalculate the normal, 如果去掉这个process, 整体性能其实是compute shader tessellation要好一些


//#v(15pt)
//#block[
//  #text(size: 15pt, weight: 700,)[Compare to Nanite]
//]
//#v(15pt)
//
//Although the prototype presented in this project does not match Nanite in terms of system complexity, performance optimization, or visual quality, the comparison still offers valuable insights.
//
//todo


// #v(15pt)
// #block[
//   #text(size: 15pt, weight: 700,)[Compare to Nanite]
// ]
// #v(15pt)
//
// // 虽然不论在系统复杂度，性能优化以及视觉效果上来说，本项目提出出的prototype都没办法和nanite相提并论，但是跟他比比还是很有借鉴价值的
//
// Although the prototype presented in this project cannot match Nanite in terms of system complexity, performance optimization, or visual quality, comparing with it still provides valuable insights.
//
// 因为nanite是动态是动态straming不同lod的cluster，

// #figure(
//   image("figures/my.png", width: 50%),
//   caption: [
//     Missing
//   ],
// )


//=== Summary

//The following charts demonstrate the ...


// #figure(
//   image("figures/my.png", width: 50%),
//   caption: [
//     Missing
//   ],
// )

// #figure(
//   image("figures/my.png", width: 50%),
//   caption: [
//     Missing
//   ],
// )
