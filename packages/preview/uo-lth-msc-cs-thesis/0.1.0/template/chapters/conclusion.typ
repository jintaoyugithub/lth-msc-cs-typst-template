= Conclusion

_In this section we present the summary of this thesis and answer the research questions._
#v(15pt)

== Key Findings

This thesis focus on presenting a prototype framework of how we can apply compute shader to reconstruct geometry's fidelity in realtime, especialy for static mesh. Even without targeted optimization, its performance is already comparable to hardware tessellation. More importantly, its programmable and pattern-driven nature provides a level of flexibility that fixed-function pipelines lack, allowing developers to tailor the tessellation process for different use cases. Furthermore, the framework's design shows potential for handling animated geometry, where animation can be applied to a coarse base mesh while finer detail is generated at render time.

While our approach offers both performance gains and greater flexibility in engine-level, its practical application still show several important limitations and challenges. Since it is not a true subdivision surface technology, simply increasing the number of triangles cannot effectively improve the smoothness of the model surface and lacks the desired visual effect in character rendering. 

In the case of static models, we found that this method is also far less efficient in terms of memory efficiency and detail reduction than the current mainstream virtualized geometry technique. The main reasons are as follows. 

Model detail reduction using displacement mapping faces several challenges. On the one hand, high-precision mapping imposes significant memory pressure, which can be partially mitigated by virtual texturing, but the effect is still limited. On the other hand, obtaining accurate displacement values often requires additional processing, and highly modeled geometry often contain tens or even hundreds of millions of triangles, resulting in extremely high resolution textures and even multiple maps covering different parts of the character's body.

In addition, topological limitations cannot be ignored. Displacement mapping is not a one-size-fits-all approach, for instance, a sphere cannot be transformed into a circle by displacement, which requires strict control of the structural layout during the creation of the base coarse model to ensure that subsequent displacement mapping can effectively reconstruct the target shape. Finally, since the compute shader needs to write the generated vertex data back to the GPU memory, keeping the duplicate vertices generated at the common edges will not only waste memory, but also reduce the rendering efficiency, e.g. triggering a lot of unnecessary vertex shader calls. Therefore, additional de-duplication algorithms are needed.

Overall, we find that compute-shader-based tessellation presents significant potential for real-time geometry reconstruction. Its programmable flexibility and competitive performance make it a promising alternative to traditional hardware tessellation. We hope this work can inspire further exploration into leveraging compute shaders for efficient, high-fidelity rendering, particularly in scenarios involving complex surface detail and potentially animated assets.

//1. 不是subd, 徒劳的只是增加三角形的密度, 并没有smooth模型表面, 在角色渲染上没有很好的视觉效果

//2. 对于static mesh来说 远没有virtualize geometry在内存效率和还原能力上来说

//3. 用displacement mapping还原其细节本身存在很多的挑战, 内存方面,当然可以用virtualize texture来解决

//- 不得不使用一些别的手段来获得更加精确的displace value

//- 因为建模软件中的模型往往三角形数量非常大,可能有几十到几百million, 对texture的resolution非常高,甚至可能需要好几张来displace一个character身体的不同部位

//-opology也是一个很大的问题, displacement并不是万能的, 举个例子我们没办法讲一个spher displace成一个torus,因为他们两个的topology其实并不相同, 这就造成了在制作coarse mesh的时候要非常注意character的某些部分以至于后续能能够得到较好的displacement mapping效果

//3. 我们必须有额外的算法来remove 在shared edge上生成的duplicate vertices, 毕竟compute shader需要将生成的数据写会gpu内存, duplicate vertices不仅造成更多不必要的内存浪费, 还是影响了渲染效率, 比如invoke很多没有必要的vertex shader

//整体上来说, compute shader tessellation show the promissing potencial in 
                                                                                            
//而对于需要处理大量动画计算的skeletal mesh, 这种coarse mesh 加上 tessellation的方式的确能够帮助开发人员在引擎中更好的控制模型以及获得更好的性能表现,因为只需要对coarse mehs做动画计算, 利用tessellation来还原模型精度

//在渲染效率和细粉效率上,尽管我们并没有做什么优化, 性能已经可以和hardware tessellation不相上下了, 而且这种pattern based的方式也为开发人员提供了足够的灵活性, 也提供了优化空间,不想传统的,都是fixed,没办法自己做优化. 

== Research Questions

With all the insights gathered through out whole thesis work, we present our answer to the research questions mentioned in the previous chapter as follows.

#v(15pt)

#block[_1. How can compute shader be effectively utilized to implement an efficient and flexible real-time surface tessellation method?_]

#v(15pt)
//由于gpu simd的特性, 我们发现这种pre computed pattern based的方法可以很好的利用gpu的特性, 通过很少的内存开销, 利用大量的compute shader来执行简单的barycentric interpolation的计算来生成大量的primitive in the gpu on the fly, its fully programmable and pattern-driven nature provides a level of flexibility that fixed-function pipelines lack, allowing developers to tailor the tessellation process for different use cases.
Due to the SIMD nature of modern GPUs, we find that a pre-computed, pattern-based tessellation approach effectively leverages the parallel architecture of the GPU. With minimal memory overhead, a high volume of primitives can be generated on the fly entirely on the GPU by large numbers of compute shader threads performing simple barycentric interpolation operations in parallel. This method is highly programmable and pattern-oriented, giving developers fine-grained control over the tessellation process and enabling adaptation to a wide range of rendering scenarios.
 
//large numbers of compute shader threads can perform simple barycentric interpolation operations in parallel to generate a high volume of primitives on the fly entirely on the GPU.

//high volume of primitvies can be generated on the fly entirely on the GPU through large numbers of compute shader threads with onply simple barycentric interpolation operation in parallel.

#v(15pt)

#block[_2. What are the trade-offs between visual fidelity and rendering efficiency when using a compute shader-based tessellation method compared to alternative approaches?_]

#v(15pt)
//对于直接渲染高精度模型来说, 无论是在渲染效率还是内存占用上都非常有利, 但是直接通过displacement texture还原的视觉效果和原始模型还存在一定的差距. 通过对比hardware tessellation, 在渲染效率上cs tessellation已经可以和其表现相差无几, 但是由于hardware tessellation天生hardcode在gpu渲染管线内部, 与其他stage合作良好, hw生成的smaller primitvies可以直接stream到gpu cache中而避免写会内存的io操作消耗以及内存开销

//而对比更加advance的geometry processing技术nanite来说, 在渲染static mesh上, 由于nanite是通过动态的streaming原始模型的不同pieces, 他的做法天然保存者high fidelity model的拓扑, 法线等信息.
//但是对于animated mesh来说, our approach在性能上应该能有这不少的提升, 因为我们可以通过base mesh来执行动画, 然后动态的refined这个mesh从而避免给太多定点做动画计算.

For direct rendering of high-precision models, using this method has obvious advantages in terms of rendering efficiency and memory consumption. However, there is still a gap between the visual effects reconstructed by relying only on displacement mapping and the original high-precision model.

Compared with hardware-level tessellation, compute shader approach is close to the same performance in rendering. However, since hardware tessellation is a fixed feature deeply integrated into the GPU rendering pipeline, the smaller primitvies generated by hardware tessellation are able to directly stream into the GPU cache, thus avoiding the I/O consumption and extra memory overhead caused by writing back to memory, which is still an advantage in terms of efficiency and resource scheduling.

In contrast to Nanite, the latter is able to preserve high-fidelity information, including the original model’s topology and normals, by dynamically streaming different segments of the mesh on demand during static mesh rendering, offering a clear advantage in visual fidelity. However, compute shader tessellation has potential performance advantages when dealing with animated models. Our approach allows us to perform animation computation only on the simplified base mesh, and then complement the details in real-time, thus significantly reducing the burden of animation computation on high dense vertices.
#v(15pt)

#block[_3. Is it feasible to achieve high-fidelity geometry reconstruction in real-time rendering using software-based tessellation combined with displacement mapping? What are the technical challenges involved in this approach?_]

#v(15pt)
//Instead of simply answering yes or no, I would like to 这个组合有potencial能够在实时渲染中还原模型的精度, 从前面的章节我们已经可以看到本文提出的framework已经可以高效的动态生成大量的三角形, 但是我们仍需要解决一些remain challenges.


Rather than simply answering “yes” or “no” to this question, it is more accurate to say that this combination has a clear potential for restoring high-fidelity geometry in real-time rendering. As demonstrated earlier, the framework proposed in this thesis has been able to efficiently and dynamically generate a large number of triangles on the GPU, showing good performance and flexibility.

However, there are still a number of key issues mentioned aboved that need to be addressed in order to fully capitalize on the benefits of this approach. These challenges include the lack of surface smoothness due to the lack of realistic subdivision, the memory and accuracy pressure from displacement mapping, topology constraints, and the additional processing required to remove redundant vertices. While these issues do not negate the feasibility of the approach, they indicate that the scheme still needs further optimization and refinement before it can be widely applied in real production environments.
#v(15pt)


