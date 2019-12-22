/**
 * @File Name          : ObjectXml.cls
 * @Description        : 
 * @Author             : victor.saranchuk@koroka.solution
 * @Group              : 
 * @Last Modified By   : victor.saranchuk@koroka.solution
 * @Last Modified On   : 21.12.2019, 15:14:46
 * @Modification Log   : 
 * Ver       Date            Author                         Modification
 * 1.0    21.12.2019   victor.saranchuk@koroka.solution     Initial Version
**/
public virtual class ObjectXml {
    
    public ObjectXml.Describe describe {get; private set;}
    
    private String value {private get; private set;}
    private List<ObjectXml> objList {private get; private set;}
    
    public ObjectXml(ObjectXml.Describe describe)
    {
        this.objList = new List<ObjectXml>();
        if (describe == NULL) this.describe = new ObjectXml.Describe();
        else this.describe = describe;
    }
    public ObjectXml()
    {
        this(new ObjectXml.Describe());
    }
    public ObjectXml(ObjectXml.Describe describe, Object obj)
    {
        this(describe);
        if (obj == NULL) return;
        else if 
            (
                obj instanceOf Boolean  ||
                obj instanceOf Datetime ||
                obj instanceOf Decimal  ||
                obj instanceOf Long     ||
                obj instanceOf String   ||
                obj instanceOf Time
            ) 
        {
            if(String.isBlank(this.describe.localName)) this.describe.localName = 'Element';
            this.setValue(String.valueOf(obj));
        }
        else if (obj instanceOf List<ObjectXml>) 
        {
            if(String.isBlank(this.describe.localName)) this.describe.localName = 'List';
            this.objList.addAll((List<ObjectXml>)obj);      
        }
        else if (obj instanceOf ObjectXml) 
        {
            this.describe = ((ObjectXml) obj).describe;
            if(String.isBlank(this.describe.localName)) this.describe.localName = 'Element';
            this.value = ((ObjectXml) obj).getString();
            this.objList = ((ObjectXml) obj).getList();
        }
        else if (obj instanceOf List<Object>) 
        {    
            if (String.isBlank(this.describe.localName))this.describe.localName = 'List';
                for (Object obj_i : (List<Object>)obj) 
                    this.put(new ObjectXml(obj_i));
        }
        else
        {
            String className = String.valueOf(obj).subStringBefore(':');
            if(String.isBlank(describe.localName)) this.describe.localName = String.isNotBlank(className) ? className : 'Element';
            Map<String, Object> objectAsMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(obj));
            for (String propertyName_i : objectAsMap.keySet())
            {
                Object obj_i = objectAsMap.get(propertyName_i);
                ObjectXml objXml_i = new ObjectXml(propertyName_i, obj_i);
                this.objList.add(objXml_i);
            }
        }
        
    }
    public ObjectXml(String localName, Object obj)
    {
        this(new ObjectXml.Describe(localName), obj);
    }
    public ObjectXml(Object obj)
    {
        this('', obj);
    }
    
    /**
    * @description 
    * @author victor.saranchuk@koroka.solution | 21.12.2019 
    * @param List<Object> objList 
    * @return void 
    **/
    public void putAll(List<Object> objList)
    {
        if(objList != NULL && !objList.isEmpty())
        {
            if (!this.isString()) 
            {
                if (objList[0] instanceOf ObjectXml)
                    this.objList.addAll((List<ObjectXml>)objList);
                else
                {
                    List<ObjectXml> objXmlList = new List<ObjectXml>();
                    for (Object obj_i : objList)
                        objXmlList.add(new ObjectXml(obj_i));
                    this.objList.addAll(objXmlList);
                }
            }
            else throw new XmlException('You can not put Objects into the String Entity');
        }
    }
    /**
    * @description 
    * @author victor.saranchuk@koroka.solution | 21.12.2019 
    * @param String value 
    * @return void 
    **/
    public void setValue(String value)
    {
        if(this.objList.isEmpty()) this.value = value;
        else throw new XmlException('You can not put Objects into the String Entity');
    }
    /**
    * @description 
    * @author victor.saranchuk@koroka.solution | 21.12.2019 
    * @param String localName 
    * @param String value 
    * @return void 
    **/
    public void setValue(String localName, String value)
    {
        this.describe.localName = localName;
        if(this.objList.isEmpty()) this.value = value;
        else throw new XmlException('You can not put Objects into the String Entity');
    }
    
    /**
    * @description 
    * @author victor.saranchuk@koroka.solution | 21.12.2019 
    * @param String localName 
    * @param Object obj 
    * @return void 
    **/
    public void put(String localName, Object obj)
    {
        if (!this.isString())
        {
            if (obj != NULL)
            {
                if (obj instanceOf ObjectXml) 
                {
                    if (String.isNotBlank(localName)) ((ObjectXml)obj).describe.localName = localName;
                    this.objList.add((ObjectXml)obj);
                }
                else this.objList.add(new ObjectXml(localName, obj));
            }
        }
        else throw new XmlException('You can not put Objects into the String Entity');
    }
    /**
    * @description 
    * @author victor.saranchuk@koroka.solution | 21.12.2019 
    * @param Object obj 
    * @return void 
    **/
    public void put(Object obj)
    {
        this.put(NULL, obj);
    }
    
    /**
    * @description 
    * @author victor.saranchuk@koroka.solution | 21.12.2019 
    * @param String localName 
    * @return ObjectXml 
    **/
    public ObjectXml getFirst(String localName)
    {
        ObjectXml target;
        for (ObjectXml obj_i : this.objList) if (obj_i.describe.localName == localName) { target = obj_i; break; }
        return target;
    }
    /**
    * @description 
    * @author victor.saranchuk@koroka.solution | 21.12.2019 
    * @param String localName 
    * @return ObjectXml 
    **/
    public ObjectXml getLast(String localName)
    {
        ObjectXml target;
        for (ObjectXml obj_i : this.objList) if (obj_i.describe.localName == localName) target = obj_i;
        return target;
    }
    /**
    * @description 
    * @author victor.saranchuk@koroka.solution | 21.12.2019 
    * @param Integer index 
    * @return ObjectXml 
    **/
    public ObjectXml get(Integer index)
    {
        ObjectXml target;
        if (this.objList.size() == index + 1) target = this.objList.get(index);
        return target;
    }
    /**
    * @description 
    * @author victor.saranchuk@koroka.solution | 21.12.2019 
    * @param String localName 
    * @return List<ObjectXml> 
    **/
    public List<ObjectXml> getAll(String localName)
    {
        List<ObjectXml> targetList = new List<ObjectXml>();
        for (ObjectXml obj_i : this.objList) if (obj_i.describe.localName == localName) targetList.add(obj_i);
        return targetList;
    }
    /**
    * @description 
    * @author victor.saranchuk@koroka.solution | 21.12.2019 
    * @return String 
    **/
    public String getString()
    {
        return this.value;
    }
    /**
    * @description 
    * @author victor.saranchuk@koroka.solution | 21.12.2019 
    * @return List<ObjectXml> 
    **/
    public List<ObjectXml> getList()
    {
        return this.objList;
    }
    /**
    * @description 
    * @author victor.saranchuk@koroka.solution | 21.12.2019 
    * @param String localName 
    * @return Attribute 
    **/
    public ObjectXml.Attribute getAttribute(String localName)
    {
        Attribute a;
        for (Attribute a_i : this.describe.attributes) if (a_i.localName == localName) a = a_i;
        return a;
    }
    /**
    * @description 
    * @author victor.saranchuk@koroka.solution | 21.12.2019 
    * @param String localName 
    * @param String value 
    * @return void 
    **/
    public void addAttribute(String localName, String value)
    {
        this.describe.attributes.add(new ObjectXml.Attribute(localName, value));
    }
    /**
    * @description 
    * @author victor.saranchuk@koroka.solution | 21.12.2019 
    * @param String localName 
    * @param String value 
    * @return void 
    **/
    public void addNameSpace(String prefix, String namespaceURI)
    {
        this.describe.namespaces.add(new ObjectXml.Namespace(prefix, namespaceURI));
    }

    /**
    * @description 
    * @author victor.saranchuk@koroka.solution | 21.12.2019 
    * @return Boolean 
    **/
    protected Boolean isString()
    {
        return String.isNotBlank(this.value);
    }
        
    /**
    * @description 
    * @author victor.saranchuk@koroka.solution | 21.12.2019 
    * @return Boolean 
    **/
    protected Boolean isEmpty()
    {
        return String.isBlank(this.value) && this.objList.isEmpty();
    }
    
    /**
    * @description 
    * @author victor.saranchuk@koroka.solution | 21.12.2019 
    * @return String 
    **/
    protected String getClassName()
    {
        return String.valueOf(this).subStringBefore(':');
    }
    
    /**
    * @description 
    * @author victor.saranchuk@koroka.solution | 21.12.2019 
    * @param Serialization service 
    * @return void 
    **/
    protected void serialize(Serialization service)
    {
        if(this.describe.localName == null) this.describe.localName = this.getClassName();
        if(this.isEmpty()) 
        {
            if(this.describe.writeIfEmpty || !this.describe.isEmpty())service.writeEmptyElement(this.describe);
        }
        else 
        {
            service.writeStartElement(this.describe);
            if ( String.isNotBlank(this.value) ) service.writeCharacters(this.value);
            else if ( !this.objList.isEmpty() ) for (ObjectXml obj_i : this.objList) obj_i.serialize(service);
            service.writeEndElement();
        }
    }
    
    /**
    * @description 
    * @author victor.saranchuk@koroka.solution | 21.12.2019 
    * @return String 
    **/
    public String serialize()
    {
        if(this.describe.localName == NULL) this.describe.localName = 'RootElement';
        Serialization service = new Serialization();
        this.serialize(service);
        String result = service.writer.getXmlString();
        if (String.isNotBlank(result) && !result.endsWith('>')) result += '/>';
        return result;
    }
    
    /**
    * @description 
    * @author victor.saranchuk@koroka.solution | 21.12.2019 
    * @param String str 
    * @return ObjectXml 
    **/
    public static ObjectXml deserialize(String str)
    {
        Dom.Document doc = new Dom.Document();
        doc.load(str);
        Dom.XmlNode rootNode = doc.getRootElement();
        ObjectXml obj = new ObjectXml();
        return obj.deserialize(rootNode, NULL);
    }
    
    /**
    * @description 
    * @author victor.saranchuk@koroka.solution | 21.12.2019 
    * @param Dom.XmlNode node 
    * @param Map<String String> prefixToNamespaceURIMap 
    * @return ObjectXml 
    **/
    protected ObjectXml deserialize(Dom.XmlNode node, Map<String, String> prefixToNamespaceURIMap)
    {   
        if (prefixToNamespaceURIMap == NULL) prefixToNamespaceURIMap = new Map<String, String>();
        String namespace = node.getNamespace();
        Boolean mapContainsNameSpace = prefixToNamespaceURIMap.values().contains(namespace);
        String prefix;
        if ( String.isNotBlank(namespace) ) 
        {
            prefix = node.getPrefixFor(namespace);
            prefixToNamespaceURIMap.put(prefix, namespace);
        }
        
        ObjectXml obj;
        if ( String.isBlank(node.getText()) )
        {
            obj = new ObjectXml();
            
            for ( Dom.XmlNode innerNode_i : node.getChildElements() )
            {
                obj.put(deserialize(innerNode_i, prefixToNamespaceURIMap));
            }
        }
        else
        {
            obj = new ObjectXml(node.getText());
        }
        obj.describe.localName = node.getName();
        obj.describe.attributes.addAll(deserializeAttributes(node));
        
        if ( String.isNotBlank(namespace) ) 
        {
            obj.describe.prefix = prefix;
            obj.describe.namespaceURI = namespace;
            if ( !mapContainsNameSpace ) obj.describe.namespaces.add(new ObjectXml.Namespace(obj.describe.prefix, namespace));
        }
        obj.describe.writeIfEmpty = true;
        return obj;
    }

    /**
    * @description 
    * @author victor.saranchuk@koroka.solution | 21.12.2019 
    * @param String xmlString 
    * @param System.Type apexType 
    * @return Object 
    **/
    public static Object deserialize(String xmlString, System.Type apexType)
    {
        return JSON.deserialize(JSON.serialize(ObjectXml.deserialize(xmlString).deserialize()), apexType);
    }
    
    /**
    * @description 
    * @author victor.saranchuk@koroka.solution | 21.12.2019 
    * @return Object 
    **/
    protected Object deserialize()
    {
        Object obj;
        if ( this.isString() ) obj = this.getString();
        else 
        {
            Map<String, Object> nameToValueMap = new Map<String, Object>();
            for (ObjectXml property_i : this.getList())
                nameToValueMap.put(property_i.describe.localName, property_i.deserialize());
            for (ObjectXml.Attribute attribute_i : this.describe.attributes)
                nameToValueMap.put(attribute_i.localName, attribute_i.value);
            obj = JSON.deserializeUntyped(JSON.serialize(nameToValueMap));
        }
        return obj;
    }

    /**
    * @description 
    * @author victor.saranchuk@koroka.solution | 21.12.2019 
    * @param Dom.XmlNode node 
    * @return List<ObjectXml.Attribute> 
    **/
    protected List<ObjectXml.Attribute> deserializeAttributes(Dom.XmlNode node)
    {
        List<ObjectXml.Attribute> attributes = new List<ObjectXml.Attribute>();
        for (Integer i = 0; i < node.getAttributeCount(); i++)
        {
            String key = node.getAttributeKeyAt(i);                            
            String namespace = node.getAttributeKeyNsAt(i);                     
            String namespaceValue = node.getAttributeValueNs(key, namespace); 
            String value = node.getAttributeValue(key, namespace);                                                                                
            attributes.add(new ObjectXml.Attribute(namespace != NULL ? node.getPrefixFor(namespace) : NULL, namespace, key, value));
        }
        return attributes;
    }
    
    /**
    * @description 
    * @author victor.saranchuk@koroka.solution | 21.12.2019 
    * @param Dom.XmlNode node 
    * @return List<ObjectXml.NameSpace> 
    **/
    protected List <ObjectXml.NameSpace> deserializeNamespaces(Dom.XmlNode node) 
    {
        Map<String, String> namespacesMap = new Map<String, String>();
        List <ObjectXml.NameSpace> namespaces = new List <ObjectXml.NameSpace>();
        for (Integer i = 0; i < node.getAttributeCount(); i++)
        {
            String key = node.getAttributeKeyAt(i);
            String namespace = node.getAttributeKeyNsAt(i);
            String namespaceValue = node.getAttributeValueNs(key, namespace);
            namespacesMap.put(key, namespace);            
        }
        for (String key_i : namespacesMap.keySet())
            namespaces.add(new ObjectXml.Namespace(key_i, namespacesMap.get(key_i)));
        return namespaces;
    }
    
    public class Describe
    {
        public String prefix {get; set;}
        public String localName {get; set;}
        public String namespaceURI {get; set;}
        public List<Namespace> namespaces {get; set;}
        public List<Attribute> attributes {get; set;}
        public Boolean writeIfEmpty {get; set;}
        
        public Describe(String prefix, String localName, String namespaceURI, List<Namespace> namespaces, List<Attribute> attributes, Boolean writeIfEmpty)
        {
            this.prefix = prefix;
            this.localName = localName;
            this.namespaceURI = namespaceURI;
            this.namespaces = namespaces != null ? namespaces : new List<Namespace>();
            this.attributes = attributes != null ? attributes : new List<Attribute>();
            this.writeIfEmpty = writeIfEmpty != null ? writeIfEmpty : false;
        }
        
        public Describe()
        {
            this(null, null, null, null, null, null);
        }
        
        public Describe(String localName, Boolean writeIfEmpty)
        {
            this(null, localName, null, null, null, writeIfEmpty);
        }
        
        public Describe(String localName)
        {
            this(null, localName, null, null, null, null);
        }
        public Describe(Boolean writeIfEmpty)
        {
            this(null, null, null, null, null, writeIfEmpty);
        }
        
        /**
        * @description 
        * @author victor.saranchuk@koroka.solution | 21.12.2019 
        * @return Boolean 
        **/
        public Boolean isEmpty()
        {
            return this.attributes.isEmpty() && this.namespaces.isEmpty();
        }
    }
    
    public class Attribute extends Namespace
    {
        public String localName {get; set;}
        public String value {get; set;}
        
        public Attribute(String prefix, String namespaceURI, String localName, String value)
        {
            super(prefix, namespaceURI);
            this.localName = localName;
            this.value = value;
        }
        public Attribute()
        {
            this(null, null, null, null);
        }
        public Attribute(String localName, String value)
        {
            this(null, null, localName, value);
        }
    }
    public virtual class Namespace 
    {
        public String prefix {get; set;}
        public String namespaceURI {get; set;}
        
        public Namespace(String prefix, String namespaceURI)
        {
            this.prefix = prefix;
            this.namespaceURI = namespaceURI;
        }
        public Namespace()
        {
            this(null, null);
        }
    }
        
    private class Serialization
    {
        public transient XmlStreamWriter writer {private get; private set;}
        
        public Serialization()
        {
            this.writer = new XmlStreamWriter();
        }
        
        /**
        * @description 
        * @author victor.saranchuk@koroka.solution | 21.12.2019 
        * @param List<ObjectXml.Attribute> attributes 
        * @return void 
        **/
        public void writeAttributes(List<ObjectXml.Attribute> attributes)
        {
            if (attributes != null) 
                for (ObjectXml.Attribute attribute_i : attributes) 
                this.writer.writeAttribute(attribute_i.prefix, attribute_i.namespaceUri, attribute_i.localName, attribute_i.value);
        }
        
        /**
        * @description 
        * @author victor.saranchuk@koroka.solution | 21.12.2019 
        * @param List<ObjectXml.Namespace> namespaces 
        * @return void 
        **/
        public void writeNameSpaces(List<ObjectXml.Namespace> namespaces)
        {
            if (namespaces != null) 
                for (ObjectXml.Namespace namespace_i : namespaces)
                this.writer.writeNamespace(namespace_i.prefix, namespace_i.namespaceURI);
        }
        
        /**
        * @description 
        * @author victor.saranchuk@koroka.solution | 21.12.2019 
        * @param ObjectXml.Describe describe 
        * @return void 
        **/
        public void writeStartElement(ObjectXml.Describe describe)
        {
            if (describe == null) throw new XmlException('Describe object can not be null');
            this.writer.writeStartElement(describe.prefix, describe.localName, describe.namespaceURI);
            this.writeAttributes(describe.attributes);
            this.writeNameSpaces(describe.namespaces);
        }
        
        /**
        * @description 
        * @author victor.saranchuk@koroka.solution | 21.12.2019 
        * @param ObjectXml.Describe describe 
        * @return void 
        **/
        public void writeEmptyElement(ObjectXml.Describe describe)
        {
            if (describe == null) throw new XmlException('Describe object can not be null');
            this.writer.writeEmptyElement(describe.prefix, describe.localName, describe.namespaceURI);
            this.writeAttributes(describe.attributes);
            this.writeNameSpaces(describe.namespaces);
        }
        
        /**
        * @description 
        * @author victor.saranchuk@koroka.solution | 21.12.2019 
        * @param String text 
        * @return void 
        **/
        public void writeCharacters(String text)
        {
            this.writer.writeCharacters(text);
        }
        
        /**
        * @description 
        * @author victor.saranchuk@koroka.solution | 21.12.2019 
        * @return void 
        **/
        public void writeEndElement()
        {
            this.writer.writeEndElement();
        }
        
    }
    
    public class XmlException extends Exception{}
}
