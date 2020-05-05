package org.palladiosimulator.dataflow.confidentiality.pcm.model.editor.conversion;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.StructuredSelection;
import org.eclipse.ui.handlers.HandlerUtil;

public class ConvertPCMToConfidentialityHandler extends AbstractHandler {

    private static final Map<String, ResourceConverter> CONVERTERS = createConverters(); 
    
    @SuppressWarnings("unchecked")
    @Override
    public Object execute(ExecutionEvent event) throws ExecutionException {
        ISelection selection = HandlerUtil.getCurrentSelectionChecked(event);
        if (!(selection instanceof StructuredSelection)) {
            return null;
        }
        StructuredSelection structuredSelection = (StructuredSelection) selection;

        Map<String, List<IFile>> resources = ((List<Object>) structuredSelection.toList()).stream()
            .filter(IFile.class::isInstance)
            .map(IFile.class::cast)
            .collect(Collectors.groupingBy(IFile::getFileExtension));

        try {
            convert(resources);
        } catch (CoreException e) {
            throw new ExecutionException("Error during conversion of resources.", e);
        }
        
        return null;
    }

    protected void convert(Map<String, List<IFile>> resources) throws CoreException {
        for (String fileExtension : resources.keySet()) {
            ResourceConverter converter = CONVERTERS.get(fileExtension);
            if (converter != null) {
                for (IFile file : resources.get(fileExtension)) {
                    converter.convert(file);
                }
            }
        }
    }

    private static Map<String, ResourceConverter> createConverters() {
        Map<String, ResourceConverter> converters = new HashMap<>();
        converters.put("repository", new RepositoryResourceConverter());
        converters.put("usagemodel", new UsageModelResourceConverter());
        converters.put("bpusagemodel", new UsageModelResourceConverter());
        return converters;
    }

}
