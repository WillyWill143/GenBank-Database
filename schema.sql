-- table holds the words that describe a particular entry.
CREATE TABLE Keywords (
  KeywordID SERIAL PRIMARY KEY,
  Keyword VARCHAR(200) NOT NULL UNIQUE
);

-- a table stores information about the organism's taxonomy.
CREATE TABLE Taxonomic (
  TaxonomicID SERIAL PRIMARY KEY,
  Taxonomy VARCHAR(50) NOT NULL
);

-- information about the source of the sequences.
CREATE TABLE Sources (
  SourceID SERIAL PRIMARY KEY,
  Organism VARCHAR(200) NOT NULL,
  ScientificName VARCHAR(500) NOT NULL
);

-- A user-defined type to store authors' names.
CREATE TYPE ReferenceAuthors AS (
  AuthorName VARCHAR(75)
);

-- reference information for entries, including author names stored as a nested table.
CREATE TABLE Reference (
  RefID SERIAL PRIMARY KEY,
  ReferenceBases VARCHAR(50) NOT NULL,
  Title VARCHAR(200),
  Journal VARCHAR(200) NOT NULL,
  MedLine INT,
  PubMed INT,
  Comments VARCHAR(1000),
  AuthorsTbl ReferenceAuthors[]
);

-- basic information about each sequence record.
CREATE TABLE Locus (
  GI SERIAL PRIMARY KEY,
  Name VARCHAR(10) NOT NULL,
  Molecule VARCHAR(7) NOT NULL,
  SegmentType JSONB, -- using JSONB to store complex structures
  Direction VARCHAR(7) NOT NULL,
  GenBankDate DATE NOT NULL,
  GenBankDivision CHAR(3) NOT NULL,
  Comments TEXT
);

-- accession numbers and their versions.
CREATE TABLE Accession (
  AccessionID SERIAL PRIMARY KEY,
  AccessionNbr CHAR(8) NOT NULL,
  Version INT
);

-- Links the Locus table to Accession to handle multiple accessions.
CREATE TABLE LocusAccession (
  LocusAccessionID SERIAL PRIMARY KEY,
  AccessionID INT REFERENCES Accession(AccessionID),
  GI INT REFERENCES Locus(GI),
  Secondary INT
);

-- stores definitions for entries.
CREATE TABLE Definitions (
  DefID SERIAL PRIMARY KEY,
  GI INT REFERENCES Locus(GI),
  Defined TEXT NOT NULL
);

-- nucleotide sequence data and related attributes
CREATE TABLE Sequences (
  SeqID SERIAL PRIMARY KEY,
  GI INT REFERENCES Locus(GI),
  a_count INT NOT NULL,
  c_count INT NOT NULL,
  g_count INT NOT NULL,
  t_count INT NOT NULL,
  ActualSequence TEXT NOT NULL, -- Storing the sequence as text
  SeqLength INT NOT NULL
);

--  features (biological annotations) of sequences, using JSONB
CREATE TABLE Features (
  FeatureID SERIAL PRIMARY KEY,
  GI INT REFERENCES Locus(GI),
  KeyName VARCHAR(50) NOT NULL,
  Location VARCHAR(50) NOT NULL,
  Ordinal INT NOT NULL,
  FeaturesTbl JSONB NOT NULL -- JSONB to store feature descriptors and locations
);

-- links the Locus table to the Sources and Taxonomic tables.
CREATE TABLE Locus_Sources (
  GI INT REFERENCES Locus(GI),
  SourceID INT REFERENCES Sources(SourceID),
  TaxonomicID INT REFERENCES Taxonomic(TaxonomicID),
  TaxonomicLevel INT
);

-- links Locus to Keywords, allowing the attachment of multiple keywords to each sequence
CREATE TABLE LocusKeywords (
  LocusKeywordID SERIAL PRIMARY KEY,
  KeywordID INT REFERENCES Keywords(KeywordID),
  GI INT REFERENCES Locus(GI),
  OrderOfGenerality INT NOT NULL
);

-- links Locus to Reference for multiple references.
CREATE TABLE LocusReference (
  GI INT REFERENCES Locus(GI),
  RefID INT REFERENCES Reference(RefID),
  OrderOfGenerality INT NOT NULL
);

-- type for feature descriptions
CREATE TYPE Feature_Described AS (
  LabelName VARCHAR(50),
  Description TEXT
);

-- indexes

-- some foreign key indexes
CREATE INDEX idx_features_gi ON Features(GI);
CREATE INDEX idx_sequences_gi ON Sequences(GI);
-- a keyword index
CREATE INDEX idx_features_keyname ON Features(KeyName);
-- an index to help with joins
CREATE INDEX idx_locus_sources_tax_source ON Locus_Sources(TaxonomicID, SourceID);
CREATE INDEX idx_locusreference_gi_refid ON LocusReference(GI, RefID);
-- a jsonb Type index
CREATE INDEX idx_features_jsonb ON Features USING GIN (FeaturesTbl);
