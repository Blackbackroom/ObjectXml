# ObjectXml

## 
Namespace

## Attributes of xml tag
ObjectXml.Attribute
String prefix
String namespaceURI
String localName
String value

Constructors
ObjectXml.Attribute()
ObjectXml.Attribute(String prefix, String namespaceURI, String localName, String value)
ObjectXml.Attribute(String localName, String value)

## Namespaces of xml tag
ObjectXml.Namespace
String prefix
String namespaceURI

Constructors
ObjectXml.Namespace()
ObjectXml.Namespace(String prefix, String namespaceURI)

## Describe object of xml tag
ObjectXml.Describe
String prefix
String localName
String namespaceURI
List<ObjectXml.Attribute> attributes
List<ObjectXml.Namespace> namespaces
Boolean writeIfEmpty

Constructors
ObjectXml.Describe()
ObjectXml.Describe(String prefix, String localName, String namespaceURI, List<ObjectXml.Namespace> namespaces, List<ObjectXml.Attribute> attributes, Boolean writeIfEmpty)
ObjectXml.Describe(localName, writeIfEmpty)
ObjectXml.Describe(localName)
ObjectXml.Describe(writeIfEmpty)

## ObjectXml
ObjectXml class
ObjectXml.Describe describe
String value
List<ObjectXml> objList

Constructors
ObjectXml()	
ObjectXml(ObjectXml.Describe describe)
ObjectXml(ObjectXml.Describe describe, Object obj)
ObjectXml(String localName, Object obj)
ObjectXml(Object obj)

Methods
void setValue(String value)
### set value of this ObjectXml

void setValue(String localName, String value)
###	set value and localName of this ObjectXml

void putAll(List<Object> objList)
###	put a List of Objects into the objList

void put(String localName, Object obj)
###	put Object into the objList

void put(Object obj)
###	put Object into the objList. Name of class will be setted as localName if not ObjectXml

ObjectXml getFirst(String localName)

###	get first property with localName from the objList

ObjectXml getLast(String localName)

###	get last property with localName from the objList

ObjectXml get(Integer index)

###	get property from the ObjList by index

List<ObjectXml> getAll(String localName)
###	get list of objectXml instances from the objList by LocalName

String getString()
###	get value of the ObjectXml

List<ObjectXml> getList()
###	get listObj

ObjectXml.Attribute getAttribute(String localName)
###	get first attribute with localName from the describe.attributes

void addAttribute(String localName, String value)
###	add attribute to the describe.attributes

void addNameSpace(String prefix, String namespaceURI)
###	add namespace to the decribe.namespaces

String serialize()
###	serialize ObjectXml to an XML String

static ObjectXml deserialize(String str)
###	deserialize XML String to an ObjectXml

static Object deserialize(String xmlString, System.Type apexType)
###	deserialize XML String to an Object with apexType
