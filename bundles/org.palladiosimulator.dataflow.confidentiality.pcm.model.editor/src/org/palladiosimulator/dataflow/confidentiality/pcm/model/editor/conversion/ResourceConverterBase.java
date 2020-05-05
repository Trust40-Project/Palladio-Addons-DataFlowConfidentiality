package org.palladiosimulator.dataflow.confidentiality.pcm.model.editor.conversion;

import java.io.IOException;
import java.io.InputStream;
import java.io.StringWriter;
import java.nio.charset.StandardCharsets;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Objects;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.apache.commons.io.IOUtils;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.presentation.CharacterizedActionsEditorPlugin;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

public class ResourceConverterBase implements ResourceConverter {

    protected static class TypeReplacement {
        private final String nodeName;
        private final String oldType;
        private final String newType;

        public TypeReplacement(String nodeName, String oldType, String newType) {
            super();
            this.nodeName = nodeName;
            this.oldType = oldType;
            this.newType = newType;
        }

        public String getNodeName() {
            return nodeName;
        }

        public String getOldType() {
            return oldType;
        }

        public String getNewType() {
            return newType;
        }

    }

    private final String rootNodeName;
    private final Map<String, String> xmlNsAdditions;
    private final Collection<TypeReplacement> typeReplacements;

    public ResourceConverterBase(EClass rootClass, Map<String, String> xmlNsAdditions,
            Collection<TypeReplacement> typeReplacements) {
        this.rootNodeName = getXsiType(rootClass);
        this.xmlNsAdditions = xmlNsAdditions;
        this.typeReplacements = typeReplacements;
    }

    @Override
    public void convert(IFile file) throws CoreException {
        try {
            convertInternal(file);
        } catch (Exception e) {
            throw new CoreException(new Status(IStatus.ERROR, CharacterizedActionsEditorPlugin.getPlugin()
                .getSymbolicName(), "An error during conversion occured.", e));
        }
    }

    public void convertInternal(IFile file)
            throws ParserConfigurationException, SAXException, IOException, CoreException, TransformerException {
        
        // load model as XML
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        DocumentBuilder builder = factory.newDocumentBuilder();
        Document document = builder.parse(file.getContents());

        // modify model
        addXmlNsEntries(document);
        replaceTypes(document);

        // serialize model to string
        TransformerFactory tf = TransformerFactory.newInstance();
        Transformer transformer = tf.newTransformer();
        StringWriter writer = new StringWriter();
        transformer.transform(new DOMSource(document), new StreamResult(writer));
        String result = writer.getBuffer()
            .toString();
        InputStream is = IOUtils.toInputStream(result, StandardCharsets.UTF_8);
        
        // read string as model and serialize
        ResourceSetImpl rs = new ResourceSetImpl();
        URI rUri = URI.createPlatformResourceURI(file.getFullPath().toString(), true);
        Resource r = rs.createResource(rUri);
        r.load(is, Collections.emptyMap());
        r.save(Collections.emptyMap());

        return;
    }

    private void replaceTypes(Document document) {
        for (TypeReplacement typeReplacement : typeReplacements) {
            NodeList candidates = document.getElementsByTagName(typeReplacement.getNodeName());
            for (int i = 0; i < candidates.getLength(); i++) {
                Element candidate = (Element) candidates.item(i);
                String currentType = candidate.getAttribute("xsi:type");
                if (Objects.equals(typeReplacement.getOldType(), currentType)) {
                    candidate.setAttribute("xsi:type", typeReplacement.getNewType());
                }
            }
        }
    }

    protected void addXmlNsEntries(Document document) {
        NodeList repositoryNodes = document.getElementsByTagName(rootNodeName);
        Element repositoryNode = (Element) repositoryNodes.item(0);
        for (Entry<String, String> xmlNsEntry : xmlNsAdditions.entrySet()) {
            if (!repositoryNode.hasAttribute(xmlNsEntry.getKey())) {
                repositoryNode.setAttribute(xmlNsEntry.getKey(), xmlNsEntry.getValue());
            }
        }
    }

    protected static Map<String, String> createXmlNsEntries(EPackage... ePackages) {
        Map<String, Integer> nsPrefixCount = new HashMap<>();
        Map<String, String> result = new HashMap<>();

        for (EPackage ePackage : ePackages) {
            addToMap(result, nsPrefixCount, ePackage);

        }

        return result;
    }

    private static void addToMap(Map<String, String> map, Map<String, Integer> nsPrefixCount, EPackage pkg) {
        String nsPrefix = pkg.getNsPrefix();
        nsPrefixCount.putIfAbsent(nsPrefix, 0);
        int prefixCount = nsPrefixCount.get(nsPrefix);
        if (prefixCount > 0) {
            nsPrefix = nsPrefix + "_" + prefixCount;
        }
        ++prefixCount;
        nsPrefixCount.put(pkg.getNsPrefix(), prefixCount);

        map.put("xmlns:" + nsPrefix, pkg.getNsURI());
    }
    
    protected static String getXsiType(EClass clz) {
        return String.format("%s:%s", clz.getEPackage().getNsPrefix(), clz.getName());
    }

}
