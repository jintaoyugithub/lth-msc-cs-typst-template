#import "lib.typ": template, createAppendices

// Your acknowledgments (Ringraziamenti) go here
#let acknowledgements = [

#block[First and foremost, I would like to express my sincere gratitude to Electronic Arts and the Frostbite team for generously providing office space, essential hardware resources, and a supportive and welcoming work environment. Working alongside such talented and kind colleagues has enriched my experience and created many memorable moments throughout this thesis journey.]\

#block[I am especially thankful to my supervisor, Kindahl Christian, and my manager, Andreas Buller, from the Frostbite team. Their continuous guidance, valuable advice, and constructive feedback were crucial in shaping my research direction and overcoming various challenges. Their support significantly contributed to the progress and quality of this work.]\

#block[I would also like to extend my heartfelt appreciation to my supervisor at LTH, Michael Doggett. His steady insightful comments, and timely feedback helped me to clarify my ideas and improve the structure and content of this thesis.]\

#block[Finally, I am deeply grateful to my family and friends, whose unwavering support, understanding, and encouragement helped me persevere through the most difficult and stressful periods of working on this thesis alone. Their belief in me was a constant source of motivation and strength, without which this accomplishment would not have been possible.]\

//First and foremost, I would like to express my sincere gratitude to Electronic Arts and the Frostbite team for generously providing office space, essential hardware resources, and a supportive and welcoming work environment. Working alongside such talented and kind colleagues has enriched my experience and created many memorable moments throughout this thesis journey.

//I am especially thankful to my supervisor, Kindahl Christian, and my manager, Andreas Buller, from the Frostbite team. Their continuous guidance, valuable advice, and constructive feedback were crucial in shaping my research direction and overcoming various challenges. Their support significantly contributed to the progress and quality of this work.

//I would also like to extend my heartfelt appreciation to my supervisor at LTH, Michael Doggett. His steady encouragement, insightful comments, and timely feedback helped me to clarify my ideas and improve the structure and content of this thesis.

//Finally, I am deeply grateful to my family and friends, whose unwavering support, understanding, and encouragement helped me persevere through the most difficult and stressful periods of working on this thesis alone. Their belief in me was a constant source of motivation and strength, without which this accomplishment would not have been possible.

#v(15pt)
#block[_Jintao Yu_]
]

// Your abstract goes here
#let abstract = [

#show link: underline

Traditional hardware-based tessellation has long been used for surface refinement in real-time rendering, yet suffers from limited flexibility, lack of programmability, and inefficient handling of geometry reuse. These constraints become more pronounced when adapting to modern rendering demands such as dynamic displacement, flexible LOD strategies, and memory-aware mesh reconstruction. To overcome these limitations, we introduce a compute-shader-based geometry reconstruction framework that leverages precomputed tessellation patterns to dynamically refine coarse meshes in real time. //Our method separates the refinement process from the fixed-function pipeline, enabling fine-grained control over tessellation factors, visibility-based culling, displacement mapping, and normal recalculation. 

The proposed system is fully programmable, supports arbitrary topologies, and enables GPU-side generation of high-density primitives with efficient memory usage. Through experiments, we compare our method against widely adopted approaches. We demonstrate that our method reduces mesh loading times and improves rendering efficiency while maintaining comparable visual quality. This work contributes a practical, scalable tessellation solution, and offers a step toward flexible, shader-driven geometry pipelines suited for future real-time graphics applications.

#v(20pt)
#line(length:100%, stroke: 0.3pt)
#v(15pt)
]

#show: template.with(
  title: [Real-Time Geometry Reconstruction with Compute Shader Tessellation],
  se_title: [],
  thesis_number: [LU-CS-EX: XXXX-XX],
  issn: [XXXX-XXXX],

  subtitle: [Master's Thesis],

  students: (
    (
      name: [Jintao Yu], 
      email: "jintaoyuemail@gmail.com"
    ),
  ),

  // Change to your supervisor's name
  supervisors: (
    (
      name: [Kindahl Christian], 
      email: "ckindahl@ea.com"
    ),
    (
      name: [Michael Doggett], 
      email: "michael.doggett@cs.lth.se"
    ),
  ),
  
  // Change to your examiner's name
  examiner: (
    (
      name: [Mattias Wallergård],
      email: "mattias.wallergard@design.lth.se"
    )
  ),

  // Customize with your own school and degree
  affiliation: (
    university: [LTH | Lund University],
    department: [Department of Design Science],
    company: [Electronic Arts]
  ),

  lang: "GB",

  acknowledgements: acknowledgements,
  abstract: abstract,

  keywords: [Computer Graphics, Geometry Processing, GPU-based Tessellation, Mesh Refinement] 

  // popular_science_summary: (
  //   title: [#lorem(6)],
  //   abstract: include("popsci/abstract.typ"),
  //   body: include("popsci/body.typ"),
  // )
)

// FYI:
//
// [] means need ref here.
// ![] means need images here.
// m[] means equation
//
// some abbr, 10+ can have a new page
// - glsl
// - cuda
// - lod
// - ssbo
// - ubo
// - gpgpu
// - cuda
// - opencl
// - vr
// - ar
// - opengl
// - directx

#text(weight: 700, size: 20pt)[List of abbreviations]
#v(50pt)

// #block[
//   #text(weight: 700)[GLSL]\
//   #text(weight: 700)[CUDA]\
//   #text(weight: 700)[LODs]\
//   #text(weight: 700)[SSBO]\
//   #text(weight: 700)[UBO]\
//   #text(weight: 700)[VR]\
//   #text(weight: 700)[AR]\
//   #text(weight: 700)[GPGPU]\
//   #text(weight: 700)[OpenGL]
// ]

#include "chapters/introduction.typ"
#include "chapters/relatework.typ"
#include "chapters/methodology.typ"
#include "chapters/implementation.typ"
#include "chapters/evalAndresults.typ"
//#include "chapters/discussion.typ"
#include "chapters/futurework.typ"
#include "chapters/conclusion.typ"


  // Bibliography
#if bibliography != none {
  show link: underline
  heading(level: 1, "References")
  show bibliography: set text(size: 1.0em)
  show bibliography: set par(spacing: 1.5em)
  set bibliography(title: none, style: "ieee.csl")
  bibliography("references.bib")
}

#createAppendices([
  #include "chapters/appendixA.typ"
])

