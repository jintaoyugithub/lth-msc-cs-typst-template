#import "lib.typ": template, createAppendices

// Your acknowledgments (Ringraziamenti) go here
#let acknowledgements = [
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

