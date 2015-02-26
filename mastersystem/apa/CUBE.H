typedef struct _Point {
	unsigned int coord[2];
} Point;

typedef struct _Vertex {
	int coord[3];
} Vertex;

//typedef long Point[2];
//typedef long Vertex[3];

typedef struct _Line {
	unsigned int coord[2];
} Line;

// cube specific
#define VERTICES (8)
#define LINES (12)
#define FACES (6)

extern int flat_vertices[VERTICES];
extern unsigned int flat_lines[LINES];
extern unsigned int flat_faces[FACES];

// Ugly hack
#define vertices(a, b) flat_vertices[(a) + (a) + (a) + (b)]
//#define vertices(a, b) flat_vertices[((a) * 3) + (b)]
#define lines(a, b) flat_lines[((a) << 1) + (b)]
#define faces(a, b) flat_faces[((a) << 2) + (b)]
