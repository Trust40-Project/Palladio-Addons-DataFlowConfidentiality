package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.ui.launchconfig;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.stream.Collectors;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.debug.core.ILaunch;
import org.eclipse.debug.core.ILaunchConfiguration;
import org.eclipse.debug.core.model.LaunchConfigurationDelegate;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.net4j.util.om.monitor.SubMonitor;
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageQuery;
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageQueryFactory;
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageQueryResult;
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.ui.Activator;
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.ui.launchconfig.config.Configuration;
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.ui.launchconfig.config.ConfigurationSerializer;
import org.palladiosimulator.dataflow.confidentiality.pcm.queryutilsorg.palladiosimulator.dataflow.confidentiality.pcm.queryutils.ModelQueryUtils;
import org.palladiosimulator.pcm.core.entity.Entity;
import org.palladiosimulator.pcm.repository.DataType;
import org.palladiosimulator.pcm.repository.PrimitiveDataType;
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

public class DataTypeUsageLaunchConfigurationDelegate extends LaunchConfigurationDelegate {

    @Override
    public void launch(ILaunchConfiguration configuration, String mode, ILaunch launch, IProgressMonitor givenMonitor)
            throws CoreException {
        SubMonitor monitor = SubMonitor.convert(givenMonitor);
        Configuration parsedConfig = parseLaunchConfig(configuration);

        monitor.beginTask("Data Type Usage Analysis", 3);

        Collection<URI> usageModelUris = getUsageModelURIs(parsedConfig);
        monitor.worked(1);

        Map<EntryLevelSystemCall, DataTypeUsageQueryResult> result = getDataTypeUsage(usageModelUris,
                monitor.newChild());
        monitor.worked(1);

        serializeToJson(parsedConfig, result, monitor.newChild());
        monitor.worked(1);

        monitor.done();
    }

    protected Collection<URI> getUsageModelURIs(Configuration parsedConfig) {
        Collection<URI> usageModelUris = parsedConfig.getUsageModels()
            .stream()
            .map(IFile::getFullPath)
            .map(IPath::toPortableString)
            .map(uri -> URI.createPlatformResourceURI(uri, false))
            .collect(Collectors.toList());
        return usageModelUris;
    }

    protected Map<EntryLevelSystemCall, DataTypeUsageQueryResult> getDataTypeUsage(Collection<URI> usageModelUris,
            IProgressMonitor monitor) throws CoreException {
        monitor.beginTask("Query usage models", usageModelUris.size());
        ResourceSetImpl rs = new ResourceSetImpl();
        ModelQueryUtils utils = new ModelQueryUtils();
        DataTypeUsageQuery query = DataTypeUsageQueryFactory.create();
        Map<EntryLevelSystemCall, DataTypeUsageQueryResult> result = new HashMap<>();
        for (URI uri : usageModelUris) {
            Resource r = rs.getResource(uri, true);
            try {
                r.load(Collections.emptyMap());
            } catch (IOException e) {
                throwCoreException("Could not read usage model.", e);
            }
            EObject rootObject = r.getContents()
                .iterator()
                .next();
            Iterable<EntryLevelSystemCall> elscs = utils.findChildrenOfType(rootObject, EntryLevelSystemCall.class);
            result.putAll(query.getUsedDataTypes(elscs));
            monitor.worked(1);
        }
        monitor.done();
        return result;
    }

    protected void serializeToJson(Configuration parsedConfig,
            Map<EntryLevelSystemCall, DataTypeUsageQueryResult> result, IProgressMonitor monitor) throws CoreException {

        Object simpleResult = createSimpleResult(result);

        GsonBuilder gsonBuilder = new GsonBuilder();
        gsonBuilder.enableComplexMapKeySerialization();
        gsonBuilder.setPrettyPrinting();
        Gson gson = gsonBuilder.create();

        String resultString = gson.toJson(simpleResult);
        IFile outputFile = parsedConfig.getOutputFile();
        try (InputStream bais = new ByteArrayInputStream(resultString.getBytes())) {
            if (outputFile.exists()) {
                outputFile.setContents(bais, IFile.FORCE, monitor);
            } else {
                parsedConfig.getOutputFile()
                    .create(bais, true, monitor);
            }
        } catch (IOException e) {
            throwCoreException("Could not serialize result.", e);
        }
    }

    protected Object createSimpleResult(Map<EntryLevelSystemCall, DataTypeUsageQueryResult> result) {
        Map<Object, Object> newResult = new HashMap<>();
        for (Entry<EntryLevelSystemCall, DataTypeUsageQueryResult> entry : result.entrySet()) {
            Object elsc = convert(entry.getKey());
            DataTypeUsageQueryResult queryResult = entry.getValue();
            List<Map<String,String>> readDts = queryResult.getReadDataTypes()
                .stream()
                .map(this::convert)
                .collect(Collectors.toList());
            List<Map<String,String>> writeDts = queryResult.getWriteDataTypes()
                .stream()
                .map(this::convert)
                .collect(Collectors.toList());
            Map<String, List<Map<String,String>>> dataTypes = new HashMap<>();
            dataTypes.put("read", readDts);
            dataTypes.put("write", writeDts);
            newResult.put(elsc, dataTypes);
        }
        return newResult;
    }

    protected Map<String,String> convert(DataType dt) {
        if (dt instanceof PrimitiveDataType) {
            return convert((PrimitiveDataType) dt);
        }
        return convert((Entity) dt);
    }

    protected Map<String,String> convert(PrimitiveDataType dt) {
        Map<String,String> result = new HashMap<>();
        result.put("name", dt.getType().getLiteral());
        return result;
    }

    protected Map<String,String> convert(Entity entity) {
        Map<String,String> result = new HashMap<>();
        result.put("name", entity.getEntityName());
        result.put("id", entity.getId());
        return result;
    }

    protected Configuration parseLaunchConfig(ILaunchConfiguration configuration) {
        Configuration parsedConfig = new Configuration();
        ConfigurationSerializer parser = new ConfigurationSerializer(parsedConfig);
        parser.read(configuration);
        return parsedConfig;
    }

    protected void throwCoreException(String message, Throwable cause) throws CoreException {
        throw new CoreException(new Status(IStatus.ERROR, Activator.getContext()
            .getBundleId(), message, cause));
    }

}
