#import "lib.typ": template, createAppendices

// Your acknowledgments (Ringraziamenti) go here
#let acknowledgements = [
  If you want to thank people, do it here, on a separate right-hand page. Both the U.S. _acknowl_-_edgments_ and the British _acknowledgements_ spellings are acceptable.

  We would like to thank Lennart Andersson for his feedback on this template.

  We would also like thank Camilla Lekebjer for her contribution on this template, as well as Magnus Hultin for his popular science summary class and example document.

  Thanks also go to the following (former) students for helping with feedback and suggestions on this template: Mikael Persson, Christoffer Lundgren, Mahmoud Nasser.
]

// Your abstract goes here
#let abstract = [

#show link: underline

TODO: 250 words

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

  keywords: [Computer Graphics, Software Tessellation, TODO],

  popular_science_summary: (
    title: [#lorem(6)],
    abstract: include("popsci/abstract.typ"),
    body: include("popsci/body.typ"),
  )

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
// - gpgpu
// - vr
// - ar
// - opengl
// - directx

#text(weight: 700, size: 20pt)[List of TODO]

#set align(left)
- references, also in the content
- abstract
- acknowledgments
- introduction ethics ...
- all images

#include "chapters/introduction.typ"
#include "chapters/relatework.typ"
#include "chapters/methodology.typ"
#include "chapters/implementation.typ"
#include "chapters/evalAndresults.typ"
//#include "chapters/discussion.typ"
#include "chapters/futurework.typ"
#include "chapters/conclusion.typ"

note: 因为mega是based mesh shader，但是很多平台现在还没有办法支持mesh shader，使用compute shader就成为了解决方案

这篇文章更多是探索如何利用compute shader和displacement mapping

意在提供一个简单的系统架构来看看如果我们要用software tessellation和displacement mapping来实现超高精度的模型会来好处和挑战


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

