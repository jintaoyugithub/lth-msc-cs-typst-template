= Discussion

#v(30pt)
_Summary of this chapter_
#v(15pt)

== Limitations

merge it with future work?

- need to allocated a large memory block for vertex buffer and index buffer, because compute shader is a seprated from traditional pipeline, the way how compute shader communicate with other shaders is to explictyly use ssbo or image

- tess table is limited, it has max tess pattern, and more pattern we use, more gpu memory we use -> use fix pattern + split triangles [2016 hw tessellation] 

- uniform, not adaptive
- topology of the coarse mesh matters!!
- need high resolution displacement texture
- displacement mapping artifacts
- unavoidable duplicate vertices, don't have a generatic way to do it, cause it's related to what kind of tess method you use, e.g. quad tree, pre-computed pattern
