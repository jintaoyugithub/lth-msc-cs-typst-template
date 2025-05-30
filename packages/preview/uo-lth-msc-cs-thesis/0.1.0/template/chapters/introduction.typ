= Introduction

_This chapter briefly introduces the background of geometry refinement techniques, discusses the main challenges in the current field, and outlines the objectives of this thesis._
#v(15pt)

== Background

Reproducing high fidelity geometry in real time play a vital role in computer graphics. In recent years, the demand for real-time photorealistic rendering has driven a surge of interest in high-resolution geometry synthesis, particularly in the context of entertainment industry, AR/VR and virtual production pipelines.

While providing benefits such as better visual effects, high-fidelity geometry also brings several challenges due to its massive data size. These challenges include reduced editability due to complex mesh topologies that are difficult to animate or manipulate in real-time engines. Increased computational burden for examples more expensive cost of lighting calculations, ray tracing, accurate collision detection, and animation of dense meshes, as well as greater memory requirements for vertices data and textures. Higher bandwidth is required between CPU and GPU and IO overhead among different shader stages and GPU memory @hoppe2023progressive.

Generating additional triangles in real-time on the gpu, so-call tessellation, is gradually becoming one of the solution for rendering a large number of triangles in real-time. In the development of geometry processing technology in these decades, this concept has given rise to a wealth of research results and technical solutions @catmull1998recursively @loop1987smooth @boubekeur2005generic @lenz2009optimized @boubekeur2008phong @vlachos2001curved, especially Hardware Tessellation @microsoftd3d11features.

However, in terms of flexibility and utilization of gpu resources, Hardware Tessellation in the traditional gpu rendering pipeline is no longer suitable for the iteration and development of modern gpu architectures. With the introduction of the compute shader @khronoscomputeshader and the concept of GPU driven pipeline @aaltonen2015siggraph, it has become possible to use gpu resources flexibly and efficiently. Based on this trend, this paper prototype a customized compute shaders pipeline to control the segmentation behavior and detail sampling process, with the intention of exploring and implementing a rendering pipeline which utilizes the compute shader tessellation with displacement mapping to restore high-precision models in real time. 

// Reproducing high fidelity geometry in real time play a vital role in computer graphics, 在最近几年，gpu硬件的快速发展，对更加真实的渲染的追求，便使得实时渲染超高精度的模型变得越发重要，尤其是在3a游戏以及VRAR行业。
//
// 在gpu中实时生成额外的所需的三角形，so-call tessellation, 逐渐成为实时渲染大量三角形的主要解决办法。在这几十年的geometry processing技术的发展中，由此概念也衍生出了丰富的研究成果和技术方案【subdivision algo，hw tessellation ...】，尤其是hw tessellation
//
// 然而，传统gpu渲染管线中hw tessellation无论是从灵活性和gpu资源的利用来看，已经没办法契合现代gpu架构的迭代与发展，随着compute shader[ref]以及gpu driven概念的introduce, 使得灵活并高效的使用gpu资源成为可能。基于这个趋势，本文采用完全自定义的计算着色器方式来控制细分行为与细节采样过程, 意在探索并implement a rendering pipeline which 利用compute shader tessellation + displacement mapping实时还原高精度模型的可能性，pros and cons，以及存在的挑战。

== Aim

This thesis explores the latest real-time surface tessellation techniques, with a specific focus on compute shader implementations. Building upon this foundation, it further develops and prototypes a rendering pipeline aimed at supporting high-fidelity geometries. Additionally, the advantages and disadvantages of compute shader-based subdivision techniques are evaluated, including their impact on rendering performance, frame rates and etc. compare to the traditional hardware tessellation and even more advence technique Nanite @karis2021nanite.

//这个thesis主要是explore 最新的实时曲面细分技术，特别是in context of compute shader，further more, 建立在此基础上，拓展并prototype an pipeline try to reproduce high fidelity geometry and asses what's the pros and cons of using compute shader based tessellation compare to traditional hardware tessellation and even more advence techs nanite，特别是在视觉效果和性能方面，like memory cost and 渲染帧率。

== Research Questions

Based on the objectives and challenges outlined above, this thesis aims to address the following research questions:

#v(15pt)

1. How can compute shaders be effectively utilized to implement an efficient and flexible real-time surface tessellation method?

2. What are the trade-offs between computational complexity and rendering performance when employing a compute shader-based tessellation solution compared to other solutions?

3. Is it feasible to achieve high-fidelity geometry reconstruction in real-time rendering using software-based tessellation combined with displacement mapping? What are the technical challenges involved in this approach?

// Based on the aim and challenges menthioned aboved, this thesis try to answer the following research questions:
//
// 1. How to utilize computer shader to implement a efficient and flexiable tessellation method?
//
// 2. What are the trade-offs between computational complexity and rendering performance when using a compute shader solution compared to other solutions?
//
// 3. 能否通过software tessellation with displacement mapping的方式在实时渲染中还原high-fidelity geometry, what's the challenges等
//
// tessellation和dis map一直是一个非常常见的组合，尤其运用在procedural terrain以及dynamic water的案例中，由于他们的拓扑结构相对简单和统一，并且normal都是垂直向上的，游戏行业中的美术资产，往往都有着更加负责的拓扑结构以及发现数据，探讨一下what's the challenges approach? 但是这些问题好像已经有研究了，并且很明显

== Contribution

TODO

== Sustainable Development Goals

// 可持续发展目标（SDGs）是联合国于2015年提出的17项全球发展目标，旨在到2030年实现消除贫困、保护地球、促进全人类和平与繁荣。这些目标涵盖教育、健康、性别平等、清洁能源、气候行动等多个方面，强调各国和各行业的合作与共同行动。

The Sustainable Development Goals, short for SDGs, are 17 global development goals put forward by the United Nations in 2015 @hak2016sustainable, aiming to eradicate poverty, protect the planet, and promote peace and prosperity for all humanity by 2030. Our project meet the targets of SDG 4: Quality Education and SDG 9: Industry, Innovation and Infrastructure.

#v(15pt)
#block[
  #text(size: 15pt, weight: 700)[Quality Education]
]
#v(15pt)

#figure(
  image("figures/sdg4.svg", width: 30%),
  caption: [
    Quality Education
  ],
)

// 通过实时高保真图形渲染技术的研究与推广，提升教育和培训系统的沉浸体验。
// 在医学培训、工程模拟、历史再现等领域，高质量图形有助于创造更具沉浸感与互动性的学习环境。
// 我的研究可以为VR/AR 教学平台提供技术支撑，推动教育公平与教学质量提升。

// 我的项目通过对实时高保真图形渲染技术的深入研究与推广，特别是在 VR/AR 教学平台中的应用，我们能够显著提升教育和培训系统的沉浸式体验。在医学培训、工程模拟以及历史再现等领域，高质量的图形渲染配合虚拟现实和增强现实技术，能够创造出更加真实且互动性强的学习环境, 契合高质量教育目标。
My project has been able to significantly enhance the immersive experience of education and training systems through in-depth research and promotion of real-time high-fidelity graphic rendering technologies, especially in VR/AR teaching platforms. In areas such as medical training, engineering simulation, and historical re-enactment, high-quality graphics rendering combined with virtual reality and augmented reality can create more realistic and interactive learning environments that meet the goals of high-quality education.


#v(15pt)
#block[
  #text(size: 15pt, weight: 700,)[Industry, Innovation and Infrastructure]
]
#v(15pt)

#figure(
  image("figures/sdg9.svg", width: 30%),
  caption: [
    Industry, Innovation and Infrastructure
  ],
)

// 我的研究推动了图形渲染技术的创新，特别是在GPU架构与计算资源的灵活利用上，属于技术基础设施与工业数字化能力建设的一部分。
//
// 与虚拟现实、游戏引擎、数字内容创作等现代工业密切相关。

// 本项目在 GPU 架构下探索灵活高效的图形细分方案，推动了面向 VR/AR、游戏引擎和数字内容创作等产业的图形渲染基础设施创新。研究成果有助于强化工业数字化能力建设，支持新兴创意产业的发展，符合产业、创新与基础设施发展目标。

This project explores flexible and efficient graphical segmentation solutions under GPU architecture, and promotes the innovation of graphical rendering infrastructure for industries such as VR/AR, game engines and digital content creation. The research results help strengthen industrial digitalization capacity building and support the development of emerging creative industries, which is in line with industry, innovation and infrastructure development goals.


// SDG 12 – Responsible Consumption and production (opt.)
// 使用计算着色器优化图形渲染流程，有可能降低对硬件资源的浪费，通过软件优化实现高质量视觉输出。
//
// 高效的细分与渲染算法可以减少对过度冗余几何数据的依赖，有助于实现更可持续的数据处理方式。

== Ethics

#v(15pt)
#block[
  #text(size: 15pt, weight: 700,)[Risks of Misleading and False Information]
]
#v(15pt)

// 高保真渲染技术在**虚拟现实（VR）与增强现实（AR）**中容易造成“真实感错觉”，尤其是在虚拟人、数字孪生等场景中。用户可能会对图像真实性产生误判，甚至在虚拟世界中产生错误的情绪或行为判断，影响心理健康或社会认知。尤需警惕技术被用于误导、欺骗或操控用户行为（例如在营销或虚假信息传播中）。

High-fidelity rendering technology in Virtual Reality and Augmented Reality is prone to cause “Illusion of reality”, especially in scenes such as avatars and digital twins. Users may misjudge the authenticity of the images, or even make wrong emotional or behavioral judgments in the virtual world, affecting mental health or social cognition. There is a particular need to be wary of technologies being used to mislead, deceive or manipulate user behavior, e.g., in marketing or disinformation dissemination.


#v(15pt)
#block[
  #text(size: 15pt, weight: 700,)[Inclusivity and Accessibility]
]
#v(15pt)

// 高质量图形技术在提升视觉体验的同时，也存在可能加剧数字鸿沟的风险。部分先进技术依赖于高端硬件设备，可能导致只有少数拥有高性能设备的用户或大型企业能够享受到其带来的优势，从而限制了技术的普及和大众的可及性。针对这一问题，探索如何在低端设备上通过合理的算法降级或近似实现高保真视觉效果，成为提升技术普及率和促进教育公平的重要方向。

While high-quality graphics technologies enhance the visual experience, there is also a risk that they may exacerbate the digital divide. The dependence of some advanced technologies on high-end hardware devices may result in only a few users with high-performance devices or large enterprises being able to enjoy the advantages they bring, thus limiting the popularization of the technologies and their accessibility to the general public. 

  To address this problem, exploring how to achieve high-fidelity visual effects on low-end devices through reasonable algorithmic degradation or approximation has become an important direction to enhance technology penetration and promote educational equity.


// 高质量图形技术是否会加剧数字鸿沟？例如：是否只服务于高端设备用户或大型企业？
// 使用到的某些技术只有高端硬件才支持
//
// 是否可以在低端设备上以合理方式下放或近似实现高保真视觉效果，从而提升大众可及性？

