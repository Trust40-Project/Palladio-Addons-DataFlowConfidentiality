package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.ui.launchconfig.config;

import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Collectors;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.debug.core.ILaunchConfiguration;
import org.eclipse.debug.core.ILaunchConfigurationWorkingCopy;

public class ConfigurationSerializer {

    private static final StringToIFileConverter IFILE_PARSER = new StringToIFileConverter();
    private static final IFileToStringConverter IFILE_SERIALIZER = new IFileToStringConverter();
    private final Configuration configuration;

    public ConfigurationSerializer(Configuration configuration) {
        this.configuration = configuration;
    }
    
    public Configuration getConfiguration() {
        return configuration;
    }

    public void read(ILaunchConfiguration launchConfig) {
        List<String> usageModelPathsAttribute = sneaky(
                () -> launchConfig.getAttribute(ConfigurationProperties.USAGE_MODELS.getKey(), Collections.emptyList()))
                    .orElse(Collections.emptyList());
        List<IFile> usageModelPaths = convertToFileList(usageModelPathsAttribute);
        configuration.setUsageModels(usageModelPaths);

        String outputAttribute = sneaky(
                () -> launchConfig.getAttribute(ConfigurationProperties.OUTPUT.getKey(), (String) null)).orElse(null);
        IFile output = convert(outputAttribute);
        configuration.setOutputFile(output);
    }

    public void write(ILaunchConfigurationWorkingCopy launchConfig) {
        List<String> usgeModelAttribute = convert(configuration.getUsageModels());
        launchConfig.setAttribute(ConfigurationProperties.USAGE_MODELS.getKey(), usgeModelAttribute);

        String outputAttribute = convert(configuration.getOutputFile());
        launchConfig.setAttribute(ConfigurationProperties.OUTPUT.getKey(), outputAttribute);
    }

    @FunctionalInterface
    private interface CoreExceptionThrowingSupplier<V> {
        V get() throws CoreException;
    }

    protected static <V> Optional<V> sneaky(CoreExceptionThrowingSupplier<V> supplier) {
        try {
            return Optional.ofNullable(supplier.get());
        } catch (CoreException e) {
            return Optional.empty();
        }
    }

    protected static List<IFile> convertToFileList(Collection<String> resources) {
        return resources.stream()
            .map(ConfigurationSerializer::convert)
            .filter(Objects::nonNull)
            .collect(Collectors.toList());
    }

    protected static List<String> convert(Collection<IFile> resources) {
        return resources.stream()
            .map(ConfigurationSerializer::convert)
            .collect(Collectors.toList());
    }

    protected static String convert(IFile resource) {
        return IFILE_SERIALIZER.convert(resource);
    }

    protected static IFile convert(String path) {
        return IFILE_PARSER.convert(path);
    }
}
