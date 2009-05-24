package org.bungeni.exist.tools.backupconverter.backup;


import java.util.Comparator;

/**
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.0
 */
public class ItemPathComparator implements Comparator<Item>
{
    @Override
    public int compare(Item item1, Item item2)
    {
        return item1.getPath().compareTo(item2.getPath());
    }
}
