import { Response } from "express";
import { AuthRequest } from "../middleware/auth";
import Category from "../models/Category";

export const createCategory = async (req: AuthRequest, res: Response) => {
    try {
        const category = await Category.create({
            userId: req.user,
            name: req.body.name
        });

        res.json(category);
    } catch (err) {
        res.status(500).json({ error: "Server error" });
    }
};

export const getCategories = async (req: AuthRequest, res: Response) => {
    try {
        const categories = await Category.find({ userId: req.user });
        res.json(categories);
    } catch (err) {
        res.status(500).json({ error: "Server error" });
    }
};

export const deleteCategory = async (req: AuthRequest, res: Response) => {
    try {
        const category = await Category.findOneAndDelete({
            _id: req.params.id,
            userId: req.user
        });

        if (!category) {
            return res.status(404).json({ error: "Category not found" });
        }
        res.json({ message: "Category deleted" });
    } catch (err) {
        res.status(500).json({ error: "Server error" });
    }
};
