package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.ui.launchconfig;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Map;
import java.util.stream.Collectors;

import javax.json.bind.Jsonb;
import javax.json.bind.JsonbBuilder;
import javax.json.bind.JsonbConfig;

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
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.net4j.util.om.monitor.SubMonitor;
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageAnalysis;
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageAnalysisResult;
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.ui.Activator;
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.ui.launchconfig.config.Configuration;
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.ui.launchconfig.config.ConfigurationSerializer;
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.ui.launchconfig.json.DataFlowGraphAdapter;
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.ui.launchconfig.json.DataTypeAdapter;
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.ui.launchconfig.json.ElscDataTypeUsages;
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.ui.launchconfig.json.EntityAdapter;
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.ui.launchconfig.json.EntityInstanceAdapter;
import org.palladiosimulator.dataflow.confidentiality.pcm.queryutilsorg.palladiosimulator.dataflow.confidentiality.pcm.queryutils.ModelQueryUtils;
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall;

public class DataTypeUsageLaunchConfigurationDelegate extends LaunchConfigurationDelegate {

    @Override
    public void launch(ILaunchConfiguration configuration, String mode, ILaunch launch, IProgressMonitor givenMonitor)
            throws CoreException {
        SubMonitor monitor = SubMonitor.convert(givenMonitor);
        Configuration parsedConfig = parseLaunchConfig(configuration);

        monitor.beginTask("Data Type Usage Analysis", 3);

        Collection<URI> usageModelUris = getUsageModelURIs(parsedConfig);
        monitor.worked(1);

        DataTypeUsageAnalysis analysis = parsedConfig.getAnalysis();
        Map<EntryLevelSystemCall, Collection<DataTypeUsageAnalysisResult>> result = getDataTypeUsage(analysis,
                usageModelUris, monitor.newChild());
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

    protected Map<EntryLevelSystemCall, Collection<DataTypeUsageAnalysisResult>> getDataTypeUsage(
            DataTypeUsageAnalysis analysis, Collection<URI> usageModelUris, IProgressMonitor monitor)
            throws CoreException {
        ResourceSetImpl rs = new ResourceSetImpl();
        ModelQueryUtils utils = new ModelQueryUtils();
        Collection<EntryLevelSystemCall> elscs = new ArrayList<>();
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
            utils.findChildrenOfType(rootObject, EntryLevelSystemCall.class)
                .forEach(elscs::add);
        }
        EcoreUtil.resolveAll(rs);
        try {
            return analysis.getUsedDataTypes(elscs, monitor);
        } catch (InterruptedException e) {
            throwCoreException("The analysis has been aborted by the user.", e);
            return null;
        }
    }

    protected void serializeToJson(Configuration parsedConfig,
            Map<EntryLevelSystemCall, Collection<DataTypeUsageAnalysisResult>> result, IProgressMonitor monitor)
            throws CoreException {

        JsonbConfig config = new JsonbConfig().withFormatting(true)
            .withAdapters(new DataTypeAdapter(), new EntityAdapter(), new EntityInstanceAdapter(),
                    new DataFlowGraphAdapter());
        Jsonb jsonb = JsonbBuilder.create(config);
        String resultString = jsonb.toJson(new ElscDataTypeUsages(result));

//        DataTypeUsageResultConverter converter = new DataTypeUsageResultConverter(result);
//        List<EntryLevelSystemCallResult> simpleResult = converter.getConversionResult();
//
//        GsonBuilder gsonBuilder = new GsonBuilder();
//        gsonBuilder.enableComplexMapKeySerialization();
//        gsonBuilder.setPrettyPrinting();
//        Gson gson = gsonBuilder.create();
//
//        String resultString = gson.toJson(simpleResult);
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
