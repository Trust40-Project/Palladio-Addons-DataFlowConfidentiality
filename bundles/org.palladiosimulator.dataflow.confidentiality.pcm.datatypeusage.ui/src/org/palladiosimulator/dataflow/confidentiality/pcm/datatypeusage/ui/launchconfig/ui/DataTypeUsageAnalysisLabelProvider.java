package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.ui.launchconfig.ui;

import org.eclipse.jface.viewers.LabelProvider;
import org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.DataTypeUsageAnalysis;

public class DataTypeUsageAnalysisLabelProvider extends LabelProvider {

    @Override
    public String getText(Object element) {
        if (element instanceof DataTypeUsageAnalysis) {
            return ((DataTypeUsageAnalysis) element).getName();
        }
        return super.getText(element);
    }

}
