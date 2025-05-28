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

Visual Quality的评估，主要从geometric fidelity，attribute coherence and shading and visual consisitency展开

=== Visibility and Tessellation

Here in Figure X, we show how the same tessellation pattern can be reused across models with completely different topologies. Despite variations in vertex connectivity and surface curvature, the pattern-based method maintains geometric correctness and visual consistency.

#figure(
  kind:image,
  caption: [haha],
  table(
    columns: 2,
    stroke:none,
    image("figures/hwtessTri.png"),
    image("figures/hwtessTri.png"),
  )
)

![terrain, monkey, bigguy with same pattern]

// Figure X compare culling impact of culling on visibility under a fixed camera view, 从第二张图片能看出，即使是简单的culling算法, 也能帮助我们剩下几乎百分之50的计算和内存开销。
Figure X compares the impact of culling operations on visibility at a fixed camera view. As can be seen in the second image, even a simple culling algorithm can help us save almost 50% of the computation and memory overhead.

#figure(
  kind:image,
  caption: [haha],
  table(
    columns: 2,
    stroke:none,
    image("figures/hwtessTri.png"),
    image("figures/hwtessTri.png"),
  )
)

![side camera view with culling, without culing]

=== Displacement mapping

// Tessellation和Displacement mapping一直在程序化地形中扮演者重要的角色，而我们的方法同样也是可以引用在常见的地形生成上的, see Figure X.
Tessellation and displacement mapping have always played an important role in procedural terrain generation, and our method can also be applied to common terrain generation scenarios, see Figure X

#figure(
  kind:image,
  caption: [haha],
  table(
    columns: 2,
    stroke:none,
    image("figures/hwtessTri.png"),
    image("figures/hwtessTri.png"),
  )
)

![terrain tessellation view, terrain displacement mapping]

To evaluate the generality of our method, we further apply displacement to complex 3D models. Figure Y shows that, even with arbitrary topology, our framework effectively refines the surface, extending beyond traditional terrain applications.

#figure(
  kind:image,
  caption: [haha],
  table(
    columns: 2,
    stroke:none,
    image("figures/hwtessTri.png"),
    image("figures/hwtessTri.png"),
  )
)

![model tessellation view, model displacement mapping]

=== Normal Recalculation

//In figure x, 我们可以看出，displacement过后的lighting计算并不是特别的准确
In figure x, we can see that the lighting calculation after displacement is not particularly accurate.

#figure(
  kind:image,
  caption: [haha],
  table(
    columns: 2,
    stroke:none,
    image("figures/hwtessTri.png"),
    image("figures/hwtessTri.png"),
  )
)

// 这是因为我们并没有对位移之后的顶点重新计算法线，一般来说deformed过后的mesh，由于表面的曲率发生变化，相应的对应的切线以及法线也会变化，see Figure X. 在terrain上可能不是很明显，Figure x中的结果说明在更复杂的3d模型上则更加容易看出
This is because we have not recalculated the normals of the displaced vertices. Generally speaking, when a mesh is deformed, the curvature of the surface changes, and so do the corresponding tangents and normals, see Figure X. While this may not be obvious on a terrain, the results in Figure X show that it is easier to see on more complex 3d models. visible on more complex 3d models.

![terrain normal recal vs. no normal recal]

#figure(
  kind:image,
  caption: [haha],
  table(
    columns: 2,
    stroke:none,
    image("figures/hwtessTri.png"),
    image("figures/hwtessTri.png"),
  )
)

![model normal recal vs. no normal recal]

#figure(
  kind:image,
  caption: [haha],
  table(
    columns: 2,
    stroke:none,
    image("figures/hwtessTri.png"),
    image("figures/hwtessTri.png"),
  )
)

//Figure X中demonstrate 3d模型的lighting在不同法线下的影响
Figure X demonstrates the impact of different normals on the lighting of the 3D model.

![lighting with normal recal vs. no normal recal]

#figure(
  kind:image,
  caption: [test],
  table(
    columns: 2,
    stroke:none,
    image("figures/my.png", height: 41%, width: 100%),
    image("figures/culling.gif")
  )
)\

== Performance Analysis

//texture, vertex data 用不同的颜色表示

// 我们在先前的chapter就有提到过，compute shader pipeline也会带来一些额外性能开销。下表详细描述了我们的framework中每个stage产生的开销，由于某些开销会根据模型不同而不同，所以这里统一采用bigguy作为input mesh data, 详细资料见table x， with fix tess pattern 70多, 因为这个pattern产生的三角形数量和hw最高tess level产生的差不多。

As we mentioned in the previous chapter, the compute shader pipeline also incurs some additional performance overheads. The following table describes in detail the overhead incurred by each stage in our framework. Since some of the overheads will be different depending on the model, here we uniformly use Bigguy as input mesh data, see table x for more details, with a fixed tessellation level of *70+*, as this pattern produces about the same number of as that generated by the highest tessellation level of Hardware Tessellation[].

#show table.cell.where(y: 0): strong
#set table(
  stroke: (x, y) => if y == 0 {
    (bottom: 0.7pt + black)
  },
  align: (left)
)

#align(center, block[
  #move(dx: 0pt)[
    #scale(85%)[
      #table(
        columns: (4cm, 8cm, 4cm),
        rows: (0.8cm),
        align: (left),
        table.header(
          [Stages],
          [Memory Footprint],
          [Execution Time],
        ),
        [Triangle Visibility], [SSBO], [All Stages], 
      )
    ]
  ]
])

//各个阶段的消耗占比如figure x所示
The consumption share of each stage is shown in figure x

#figure(
  image("figures/my.png", width: 30%),
  caption: [
    pi图
  ],
)

// 虽然记录自身框架的性能开销是必要的，但为了全面评估该方法的实用性，我们还必须将其与现有的几种主流方案进行对比。接下来，我们将依次展示与直接渲染高细节模型、硬件 Tessellation 以及 Nanite 等先进技术的性能对比结果。
While documenting the performance overhead of our own framework is necessary, in order to fully assess the utility of the approach, we must also compare it to several existing mainstream schemes. In the next section, we will show the performance results in turn against state-of-the-art techniques such as direct rendering of highly detailed models, Hardware Tessellation, and Nanite.

=== Compare to directly

#figure(
  image("figures/my.png", width: 50%),
  caption: [
    test
  ],
)

=== Compare to hardware tessellation

#figure(
  image("figures/my.png", width: 50%),
  caption: [
    test
  ],
)

=== Compare to nanite

#figure(
  image("figures/my.png", width: 50%),
  caption: [
    test
  ],
)
