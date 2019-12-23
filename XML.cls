/**
 * @File Name          : XML.cls
 * @Description        : 
 * @Author             : saranchukvm87@gmail.com
 * @Group              : 
 * @Last Modified By   : victor.saranchuk@koroka.solution
 * @Last Modified On   : 23.12.2019, 09:36:47
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    12/22/2019   saranchukvm87@gmail.com     Initial Version
**/
public without sharing class XML 
{
    /**
    * @description 
    * @author saranchukvm87@gmail.com | 12/22/2019 
    * @param Object obj 
    * @param Boolean isSelfClosedIfEmpty 
    * @return String 
    **/
    public static String serialize(Object obj, Boolean isSelfClosedIfEmpty)
    {
        return new XML.Serializator()
        .serialize( (obj instanceOf XML.XmlObject) ? (XML.XmlObject) obj : XML.createXmlObjectFromObject(NULL, NULL, NULL, obj, isSelfClosedIfEmpty) );
    }

    /**
    * @description 
    * @author saranchukvm87@gmail.com | 12/22/2019 
    * @param Object obj 
    * @return String 
    **/
    public static String serialize(Object obj)
    {
        return XML.serialize(obj, NULL);
    }

    /**
    * @description 
    * @author saranchukvm87@gmail.com | 12/22/2019 
    * @param String xmlString 
    * @param System.Type apexType 
    * @return Object 
    **/
    public static Object deserialize(String xmlString, System.Type apexType)
    {
        return new XML.Deserializator().deserialize(xmlString, apexType);
    }

    /**
    * @description 
    * @author saranchukvm87@gmail.com | 12/22/2019 
    * @param String xmlString 
    * @return Object 
    **/
    public static Object deserialize(String xmlString)
    {
        return XML.deserialize(xmlString, NULL);
    }

    /**
    * @description 
    * @author saranchukvm87@gmail.com | 12/22/2019 
    * @param String prefix 
    * @param String uri 
    * @param String name 
    * @param Object obj 
    * @param Boolean isSelfClosedIfEmpty 
    * @return XML.XmlObject 
    **/
    public static XML.XmlObject createXmlObjectFromObject(String prefix, String uri, String name, Object obj, Boolean isSelfClosedIfEmpty)
    {
        if (obj == NULL) throw new XML.XmlException('Argument can not be null');
        XML.XmlObject xmlObj;
        if ( String.isBlank(name) ) name = XML.getName(obj);
        if 
        (
            obj instanceOf Blob     ||
            obj instanceOf Boolean  ||
            obj instanceOf Datetime ||
            obj instanceOf Decimal  ||
            obj instanceOf Long     ||
            obj instanceOf String   ||
            obj instanceOf Time
        )
            xmlObj = new XML.XmlObject(prefix, uri, name, obj, isSelfClosedIfEmpty);
        else if ( obj instanceOf List<Object> || obj instanceOf Set<Object> )
        {
            xmlObj = new XML.XmlObject(prefix, uri, name, NULL, isSelfClosedIfEmpty);
            for (Object property_i : (obj instanceOf List<Object>) ? (List<Object>) obj : new List<Object>((Set<Object>) obj))
                xmlObj.addProperty(XML.createXmlObjectFromObject(NULL, NULL, NULL, obj, isSelfClosedIfEmpty));
        }
        else 
        {
            xmlObj = new XML.XmlObject(prefix, uri, name, NULL, isSelfClosedIfEmpty);
            Map<String, Object> nameToPropertyMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(obj));
            for (String propertyName_i : nameToPropertyMap.keySet())
                xmlObj.addProperty(XML.createXmlObjectFromObject(NULL, NULL, propertyName_i, nameToPropertyMap.get(propertyName_i), isSelfClosedIfEmpty));

        }    
        return xmlObj;
    }

    /**
    * @description 
    * @author saranchukvm87@gmail.com | 12/22/2019 
    * @param String name 
    * @param Object obj 
    * @param Boolean isSelfClosedIfEmpty 
    * @return XML.XmlObject 
    **/
    public static XML.XmlObject createXmlObjectFromObject(String name, Object obj, Boolean isSelfClosedIfEmpty)
    {
        return XML.createXmlObjectFromObject(NULL, NULL, name, obj, isSelfClosedIfEmpty);
    }

    /**
    * @description 
    * @author saranchukvm87@gmail.com | 12/22/2019 
    * @param String name 
    * @param Object obj 
    * @return XML.XmlObject 
    **/
    public static XML.XmlObject createXmlObjectFromObject(String name, Object obj)
    {
        return XML.createXmlObjectFromObject(NULL, NULL, name, obj, NULL);
    }

    /**
    * @description 
    * @author saranchukvm87@gmail.com | 12/22/2019 
    * @param String xmlString 
    * @return XML.XmlObject 
    **/
    public static XML.XmlObject createXmlObjectFromXml(String xmlString)
    {
        return new XML.Deserializator().deserializeXmlIntoXmlObject(xmlString);
    }

    /**
    * @description 
    * @author saranchukvm87@gmail.com | 12/22/2019 
    * @param Object obj 
    * @return String 
    **/
    private static String getName(Object obj)
    {
        String name;
        if ( obj instanceOf Boolean ) name = 'Boolean';
        else if ( obj instanceOf Date ) name = 'Date';
        else if ( obj instanceOf Time ) name = 'Time';
        else if ( obj instanceOf DateTime ) name = 'DateTime';
        else if ( obj instanceOf Id ) name = 'ID';
        else if ( obj instanceOf String ) name = 'String';
        else if ( obj instanceOf Blob ) name = 'Blob';
        else if ( obj instanceOf Integer ) name = 'Integer';
        else if ( obj instanceOf Long ) name = 'Long';
        else if ( obj instanceOf Decimal ) name = 'Decimal';
        else if ( obj instanceOf Double ) name = 'Double';
        else if ( obj instanceOf List<Object> ) name = 'List';
        else if ( obj instanceOf Set<Object> ) name = 'Set';
        else name = String.valueOf(obj).subStringBefore(':');
        if (String.isBlank(name)) name = 'Element';
        return name;
    }

    private without sharing virtual class Attribute extends Namespace
    {
        public String name {get; private set;}
        public String value {get; private set;}

        public Attribute(String prefix, String uri, String name, String value)
        {
            super(prefix, uri);
            this.name = name;
            this.value = value;
        }
        public Attribute(String name, String value)
        {
            this(NULL, NULL, name, value);
        }
    }

    private without sharing class Describe extends Attribute
    {
        public List<XML.Namespace> namespaces {get; private set;}
        public List<XML.Attribute> attributes {get; private set;}
        public Boolean isSelfClosedIfEmpty {get; private set;}

        public Describe(String prefix, String uri, String name, Object value, Boolean isSelfClosedIfEmpty)
        {
            super(prefix, uri, name, value != NULL ? ( (value instanceOf Blob) ? ((Blob)value).toString() : String.valueOf(value) ) : NULL);
            this.namespaces = new List<XML.Namespace>();
            this.attributes = new List<XML.Attribute>();
            this.isSelfClosedIfEmpty = isSelfClosedIfEmpty != NULL ? isSelfClosedIfEmpty : false;
        }

        /**
        * @description 
        * @author saranchukvm87@gmail.com | 12/22/2019 
        * @param String prefix 
        * @param String uri 
        * @return void 
        **/
        public void addNamespace(String prefix, String uri)
        {
            this.namespaces.add(new XML.Namespace(prefix, uri));
        }

        /**
        * @description 
        * @author saranchukvm87@gmail.com | 12/22/2019 
        * @param String prefix 
        * @param String uri 
        * @param String name 
        * @param String value 
        * @return void 
        **/
        public void addAttribute(String prefix, String uri, String name, String value)
        {
            this.attributes.add(new XML.Attribute(prefix, uri, name, value));
        }

        /**
        * @description 
        * @author saranchukvm87@gmail.com | 12/22/2019 
        * @param String name 
        * @param String value 
        * @return void 
        **/
        public void addAttribute(String name, String value)
        {
            this.addAttribute(NULL, NULL, name, value);
        }

    }

    private without sharing class Deserializator
    {
        /**
        * @description 
        * @author saranchukvm87@gmail.com | 12/22/2019 
        * @param String xmlString 
        * @return XML.XmlObject 
        **/
        public XML.XmlObject deserializeXmlIntoXmlObject(String xmlString)
        {
            DOM.Document domDocument = new DOM.Document();
            domDocument.load(xmlString);
            DOM.XmlNode rootNode = domDocument.getRootElement();
            return this.deserializeXmlIntoXmlObject(rootNode, new Map<String, String>());
        }

        /**
        * @description 
        * @author saranchukvm87@gmail.com | 12/22/2019 
        * @param XML.XmlObject xmlObj 
        * @return Object 
        **/
        public Object deserializeXmlObjectIntoObject(XML.XmlObject xmlObj)
        {
            Object obj;
            if ( String.isNotBlank(xmlObj.describe.value) ) obj = xmlObj.describe.value;
            else
            {
                Map<String, Object> nameToPropertyMap = new Map<String, Object>();
                for (XML.XmlObject property_i : xmlObj.properties) nameToPropertyMap.put(property_i.describe.name, this.deserializeXmlObjectIntoObject(property_i));
                for (XML.Attribute attribute_i : xmlObj.describe.attributes) nameToPropertyMap.put(attribute_i.name, attribute_i.value);
                obj = JSON.deserializeUntyped(JSON.serialize(nameToPropertyMap));
            }
            return obj;
        }

        /**
        * @description 
        * @author saranchukvm87@gmail.com | 12/22/2019 
        * @param String xmlString 
        * @param System.Type apexType 
        * @return Object 
        **/
        public Object deserialize(String xmlString, System.Type apexType)
        {
            XML.XmlObject xmlObj = this.deserializeXmlIntoXmlObject(xmlString);
            if ( apexType == NULL ) apexType = System.Type.forName(xmlObj.describe.name);
            return JSON.deserialize(JSON.serialize(this.deserializeXmlObjectIntoObject(xmlObj)), apexType);
        }

        /**
        * @description 
        * @author saranchukvm87@gmail.com | 12/22/2019 
        * @param DOM.XmlNode node 
        * @param Map<String String> prefixToUriMap 
        * @return XML.XmlObject 
        **/
        private XML.XmlObject deserializeXmlIntoXmlObject(DOM.XmlNode node, Map<String, String> prefixToUriMap)
        {
            String uri = node.getNamespace();
            String prefix;
            if ( String.isNotBlank(uri) )
            {
                prefix = node.getPrefixFor(uri);
                prefixToUriMap.put(prefix, uri);
            }
            String value = node.getText();
            XML.XmlObject xmlObj = new XML.XmlObject(prefix, uri, node.getName(), String.isNotBlank(value) ? value : NULL, true);
            for (XML.Attribute attribute_i : this.deserializeAttributes(node))
                xmlObj.addAttribute(attribute_i.prefix, attribute_i.uri, attribute_i.name, attribute_i.value);
            if ( String.isNotBlank(prefix) && !prefixToUriMap.containsKey(prefix) ) xmlObj.addNamespace(prefix, uri);
            for (DOM.XmlNode childNode_i : node.getChildElements())
            {
                xmlObj.addProperty(this.deserializeXmlIntoXmlObject(childNode_i, prefixToUriMap));
            }
            return xmlObj;
        }

        /**
        * @description 
        * @author saranchukvm87@gmail.com | 12/22/2019 
        * @param DOM.XmlNode node 
        * @return List<XML.Attribute> 
        **/
        private List<XML.Attribute> deserializeAttributes(DOM.XmlNode node)
        {
            List<XML.Attribute> attributes = new List<XML.Attribute>();
            for (Integer i = 0; i < node.getAttributeCount(); i ++)
            {
                String name = node.getAttributeKeyAt(i);                            
                String uri = node.getAttributeKeyNsAt(i);                     
                String prefix = node.getAttributeValueNs(name, uri); 
                String value = node.getAttributeValue(name, uri);                                                                                
                attributes.add(new XML.Attribute(prefix, uri, name, value));
            }
            return attributes;
        }
    }

    private without sharing virtual class Namespace
    {
        public String prefix {get; private set;}
        public String uri {get; private set;}

        public Namespace(String prefix, String uri)
        {
            this.prefix = prefix;
            this.uri = uri;
        }
    }

    private without sharing class Serializator
    {
        private XmlStreamWriter writer;
        
        public Serializator()
        {
            this.writer = new XmlStreamWriter();
        }

        /**
        * @description 
        * @author saranchukvm87@gmail.com | 12/22/2019 
        * @param XmlObject xmlObj 
        * @return String 
        **/
        public String serialize(XmlObject xmlObj)
        {
            if ( xmlObj.describe.value == NULL && xmlObj.properties.isEmpty() && xmlObj.describe.isSelfClosedIfEmpty )
                this.writeEmptyElement(xmlObj.describe);
            else 
            {
                this.writeStartElement(xmlObj.describe);
                if ( String.isNotBlank(xmlObj.describe.value) ) this.writeCharacters(xmlObj.describe.value);
                for (XML.XmlObject property_i : xmlObj.properties)
                    this.serialize(property_i);
                this.writeEndElement();
            }
            String xmlString = this.writer.getXmlString();
            if ( String.isNotBlank(xmlString) && !xmlString.endsWith('>') ) xmlString += '/>';
            return xmlString;
        }

        /**
        * @description 
        * @author saranchukvm87@gmail.com | 12/22/2019 
        * @param List<XML.Attribute> attributes 
        * @return void 
        **/
        private void writeAttributes(List<XML.Attribute> attributes)
        {
            for (XML.Attribute attribute_i : attributes)
                this.writer.writeAttribute(attribute_i.prefix, attribute_i.uri, attribute_i.name, attribute_i.value);
        }

        /**
        * @description 
        * @author saranchukvm87@gmail.com | 12/22/2019 
        * @param List<XML.Namespace> namespaces 
        * @return void 
        **/
        private void writeNamespaces(List<XML.Namespace> namespaces)
        {
            for (XML.Namespace namespace_i : namespaces)
                this.writer.writeNamespace(namespace_i.prefix, namespace_i.uri);
        }

        /**
        * @description 
        * @author saranchukvm87@gmail.com | 12/22/2019 
        * @param XML.Describe describe 
        * @return void 
        **/
        private void writeStartElement(XML.Describe describe)
        {
            this.writer.writeStartElement(describe.prefix, describe.name, describe.uri);
            this.writeAttributes(describe.attributes);
            this.writeNamespaces(describe.namespaces);
        }

        /**
        * @description 
        * @author saranchukvm87@gmail.com | 12/22/2019 
        * @param XML.Describe describe 
        * @return void 
        **/
        private void writeEmptyElement(XML.Describe describe)
        {
            this.writer.writeEmptyElement(describe.prefix, describe.name, describe.uri);
            this.writeAttributes(describe.attributes);
            this.writeNamespaces(describe.namespaces);
        }

        /**
        * @description 
        * @author saranchukvm87@gmail.com | 12/22/2019 
        * @param String text 
        * @return void 
        **/
        private void writeCharacters(String text)
        {
            this.writer.writeCharacters(text);
        }

        /**
        * @description 
        * @author saranchukvm87@gmail.com | 12/22/2019 
        * @return void 
        **/
        private void writeEndElement()
        {
            this.writer.writeEndElement();
        }
    }

    private without sharing class XmlException extends Exception
    {}

    private without sharing class XmlObject
    {
        public XML.Describe describe {get; private set;}
        public List<XML.XmlObject> properties {get; private set;}

        public XmlObject(String prefix, String uri, String name, Object obj, Boolean isSelfClosedIfEmpty)
        {
            this.properties = new List<XML.XmlObject>();
            this.describe = new XML.Describe(prefix, uri, name, obj, isSelfClosedIfEmpty);
        }

        public XmlObject(String name, Object obj, Boolean isSelfClosedIfEmpty)
        {
            this(NULL, NULL, name, obj, isSelfClosedIfEmpty);
        }

        public XmlObject(String name, Object obj)
        {
            this(NULL, NULL, name, obj, NULL);
        }

        /**
        * @description 
        * @author saranchukvm87@gmail.com | 12/22/2019 
        * @param XML.XmlObject property 
        * @return void 
        **/
        public void addProperty(XML.XmlObject property)
        {
            if ( property == NULL ) return;
            this.properties.add(property);
        }

        /**
        * @description 
        * @author saranchukvm87@gmail.com | 12/22/2019 
        * @param String prefix 
        * @param String uri 
        * @return void 
        **/
        public void addNamespace(String prefix, String uri)
        {
            this.describe.addNamespace(prefix, uri);
        }

        /**
        * @description 
        * @author saranchukvm87@gmail.com | 12/22/2019 
        * @param String prefix 
        * @param String uri 
        * @param String name 
        * @param String value 
        * @return void 
        **/
        public void addAttribute(String prefix, String uri, String name, String value)
        {
            this.describe.addAttribute(prefix, uri, name, value);
        }

        /**
        * @description 
        * @author saranchukvm87@gmail.com | 12/22/2019 
        * @param String name 
        * @param String value 
        * @return void 
        **/
        public void addAttribute(String name, String value)
        {
            this.addAttribute(NULL, NULL, name, value);
        }
        
        /**
        * @description 
        * @author saranchukvm87@gmail.com | 12/22/2019 
        * @param String name 
        * @return List<XML.XmlObject> 
        **/
        public List<XML.XmlObject> obtainPropertiesByName(String name)
        {
            List<XML.XmlObject> findedProperties = new List<XML.XmlObject>();
            for (XML.XmlObject property_i : this.properties) 
                if (property_i.describe.name == name) findedProperties.add(property_i);
            return findedProperties;
        }

        /**
        * @description 
        * @author saranchukvm87@gmail.com | 12/22/2019 
        * @param String name 
        * @return List<XML.Attribute> 
        **/
        public List<XML.Attribute> obtainAttributesByName(String name)
        {
            List<XML.Attribute> findedAttributes = new List<XML.Attribute>();
            for (XML.Attribute attribute_i : this.describe.attributes)
                if (attribute_i.name == name) findedAttributes.add(attribute_i);
            return findedAttributes;    
        }

    }
}
